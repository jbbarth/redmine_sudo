require "spec_helper"

# The elevation depends on what the session says about the resolved user, never on how the user was resolved, so a
# controller that resolves the session of a JSON request itself is
# elevated like any other session request.
describe RedmineSudo::ApplicationControllerPatch, type: :controller do
  fixtures :users

  controller(ApplicationController) do
    # How a controller keeps the session of an API request: its own lookup, which does not even call super
    def find_current_user
      user = (User.find_by_api_key(params[:key]) if params[:key].present?) || User.active.find_by(id: session[:user_id])
      user&.remote_ip = request.remote_ip
      user
    end

    def api_session; end

    def index
      render json: { id: User.current.id, admin: User.current.admin? }
    end
  end

  let(:sudoer) do
    User.find(2).tap { |user| user.update_columns(admin: false, sudoer: true) }
  end
  let(:other_user) { User.find(3) }

  before do
    User.current = nil
    Setting.rest_api_enabled = "1"
  end

  def answer
    response.parsed_body.symbolize_keys
  end

  it "elevates the user a JSON request resolved from the session" do
    session[:user_id] = sudoer.id
    session[:sudo_admin_user_id] = sudoer.id

    get :index, params: { format: "json" }

    expect(answer).to eq(id: sudoer.id, admin: true)
  end

  it "does not elevate a session that did not elevate" do
    session[:user_id] = sudoer.id

    get :index, params: { format: "json" }

    expect(answer).to eq(id: sudoer.id, admin: false)
  end

  it "does not elevate a user who was not resolved from the session that elevated" do
    session[:user_id] = sudoer.id
    session[:sudo_admin_user_id] = other_user.id

    get :index, params: { format: "json", key: other_user.api_key }

    expect(answer).to eq(id: other_user.id, admin: false)
  end

  it "does not elevate an impersonated session" do
    session[:user_id] = sudoer.id
    session[:sudo_admin_user_id] = sudoer.id
    session[:real_user_id] = other_user.id

    get :index, params: { format: "json" }

    expect(answer).to eq(id: sudoer.id, admin: false)
  end

  it "does not elevate anonymous" do
    session[:sudo_admin_user_id] = User.anonymous.id

    get :index, params: { format: "json" }

    expect(answer).to eq(id: User.anonymous.id, admin: false)
  end
end
