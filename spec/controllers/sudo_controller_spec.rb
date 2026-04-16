require "spec_helper"

describe SudoController, type: :controller do
  fixtures :users, :roles

  let(:admin_user) { User.find_by_login("admin") }

  before do
    @request.session[:user_id] = admin_user.id
    admin_user.update_columns(admin: true, sudoer: true)
    # Reset plugin settings to default (no OIDC restriction)
    Setting["plugin_redmine_sudo"] = Setting["plugin_redmine_sudo"].merge(
      "require_oidc_for_sudo"    => '',
      "required_oidc_auth_level" => '',
      "oidc_error_message"       => ''
    )
  end

  describe "GET toggle" do
    context "without OIDC restriction configured" do
      it "allows becoming user (drop admin) regardless of session" do
        get :toggle
        expect(admin_user.reload.admin?).to be false
      end

      it "allows becoming admin regardless of session" do
        admin_user.update_admin!(false)
        get :toggle
        expect(admin_user.reload.admin?).to be true
      end
    end

    context "with require_oidc_for_sudo enabled" do
      before do
        Setting["plugin_redmine_sudo"] = Setting["plugin_redmine_sudo"].merge(
          "require_oidc_for_sudo" => '1'
        )
        admin_user.update_admin!(false) # start as non-admin (wants to become admin)
      end

      it "blocks becoming admin when not logged via OIDC" do
        get :toggle
        expect(admin_user.reload.admin?).to be false
        expect(flash[:error]).to be_present
      end

      it "allows becoming admin when logged via OIDC" do
        @request.session[:logged_in_with_oidc] = true
        get :toggle
        expect(admin_user.reload.admin?).to be true
      end

      it "always allows dropping admin regardless of OIDC session" do
        admin_user.update_admin!(true)
        # no OIDC session — but dropping admin should still work
        get :toggle
        expect(admin_user.reload.admin?).to be false
        expect(flash[:error]).to be_nil
      end
    end

    context "with required_oidc_auth_level configured" do
      before do
        Setting["plugin_redmine_sudo"] = Setting["plugin_redmine_sudo"].merge(
          "required_oidc_auth_level" => "cert3"
        )
        admin_user.update_admin!(false)
      end

      it "blocks becoming admin when oidc_auth_level does not match" do
        @request.session[:logged_in_with_oidc] = true
        @request.session[:oidc_auth_level] = "eidas1"
        get :toggle
        expect(admin_user.reload.admin?).to be false
        expect(flash[:error]).to be_present
      end

      it "blocks becoming admin when logged via OIDC but auth_level absent" do
        @request.session[:logged_in_with_oidc] = true
        get :toggle
        expect(admin_user.reload.admin?).to be false
        expect(flash[:error]).to be_present
      end

      it "blocks becoming admin when not logged via OIDC at all" do
        get :toggle
        expect(admin_user.reload.admin?).to be false
        expect(flash[:error]).to be_present
      end

      it "allows becoming admin when oidc_auth_level matches" do
        @request.session[:logged_in_with_oidc] = true
        @request.session[:oidc_auth_level] = "cert3"
        get :toggle
        expect(admin_user.reload.admin?).to be true
      end
    end

    context "with custom error message configured" do
      before do
        Setting["plugin_redmine_sudo"] = Setting["plugin_redmine_sudo"].merge(
          "require_oidc_for_sudo" => '1',
          "oidc_error_message"    => "Vous devez vous connecter avec votre carte agent."
        )
        admin_user.update_admin!(false)
      end

      it "displays the custom error message instead of the default" do
        get :toggle
        expect(flash[:error]).to eq "Vous devez vous connecter avec votre carte agent."
      end
    end
  end
end
