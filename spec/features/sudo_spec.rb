require "spec_helper"

describe "Sudo", type: :request do

  fixtures :users, :roles

  #taken from core
  def log_user(login, password)
    User.anonymous
    get "/login"
    assert_equal nil, session[:user_id]
    assert_response :success
    assert_template "account/login"
    post "/login", :username => login, :password => password
    assert_equal login, User.find(session[:user_id]).login
  end

  context "toggle link" do
    it "should route to sudo#toggle" do
      assert_routing(
        { :method => :get, :path => "/sudo/toggle" },
        { :controller => "sudo", :action => "toggle" }
      )
    end

    it "should toggle sudo rights" do
      user = User.find_by_login("admin")
      user.update_attribute(:sudoer, true)
      log_user("admin", "admin")

      assert user.reload.admin?
      assert user.reload.sudoer?

      get "sudo/toggle?back_url=/my/page"
      response.should redirect_to("/my/page")
      assert !user.reload.admin?

      get "sudo/toggle?back_url=/my/page"
      response.should redirect_to("/my/page")
      assert user.reload.admin?
    end 
  end
end