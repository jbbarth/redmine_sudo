require "spec_helper"

describe "Sudo", type: :request do

  fixtures :users, :roles

  before do
    Setting.default_language = 'en'
    Setting["plugin_redmine_sudo"] = Setting["plugin_redmine_sudo"].merge(
      "require_oidc_for_sudo"    => '',
      "required_oidc_auth_level" => '',
      "oidc_error_message"       => ''
    )
  end

  # taken from core
  def log_user(login, password)
    User.anonymous
    get "/login"
    assert_equal nil, session[:user_id]
    assert_response :success
    assert_template "account/login"
    post "/login", params: { :username => login, :password => password }
    assert_equal login, User.find(session[:user_id]).login
  end

  def sudo_settings(overrides = {})
    Setting["plugin_redmine_sudo"] = Setting["plugin_redmine_sudo"].merge(overrides)
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

      get "/sudo/toggle?back_url=/my/page"
      expect(response).to redirect_to("/my/page")
      assert !user.reload.admin?

      get "/sudo/toggle?back_url=/my/page"
      expect(response).to redirect_to("/my/page")
      assert user.reload.admin?
    end

    it "should not allow a redirection to a different domain name" do
      get "/sudo/toggle?back_url=.my-custom-domain-name.com"
      expect(response).to_not redirect_to("my-custom-domain-name.com")
    end
  end

  context "enforce_oidc_sudo_restrictions" do

    let(:admin_user) { User.find_by_login("admin") }

    before do
      Setting.default_language = 'en'
      admin_user.update_columns(admin: true, sudoer: true)
    end

    context "when require_oidc_for_sudo is enabled" do
      before do
        sudo_settings("require_oidc_for_sudo" => '1')
      end

      it "demotes admin sudoer who logs in without OIDC" do
        log_user("admin", "admin")
        # session has no :logged_in_with_oidc — any request triggers the before_action
        get "/my/page"
        expect(admin_user.reload.admin?).to be false
      end

      it "does not demote a non-sudoer admin" do
        admin_user.update_columns(sudoer: false)
        log_user("admin", "admin")
        get "/my/page"
        expect(admin_user.reload.admin?).to be true
      end
    end

    context "when required_oidc_auth_level is configured" do
      before do
        sudo_settings("required_oidc_auth_level" => "cert3")
        log_user("admin", "admin")
      end

      it "demotes admin sudoer logged in without OIDC" do
        get "/my/page"
        expect(admin_user.reload.admin?).to be false
      end
    end

    context "when no OIDC restriction is configured" do
      before do
        sudo_settings("require_oidc_for_sudo" => '', "required_oidc_auth_level" => '')
        log_user("admin", "admin")
      end

      it "does not demote admin sudoer (backward compatible)" do
        get "/my/page"
        expect(admin_user.reload.admin?).to be true
      end
    end
  end
end
