require "spec_helper"

describe "API sudo elevation", type: :request do
  fixtures :users, :email_addresses, :roles

  let(:sudoer) { User.find_by_login("jsmith") }

  before do
    # jsmith is a sudoer who has currently dropped their admin rights.
    sudoer.update_columns(admin: false, sudoer: true)
    Setting["plugin_redmine_sudo"] = Setting["plugin_redmine_sudo"].merge(
      "api_sudoer_always_admin" => '1'
    )
  end

  it "grants admin-only API access to a sudoer who dropped admin rights" do
    with_settings(rest_api_enabled: '1') do
      get "/users.json", headers: { "X-Redmine-API-Key" => sudoer.api_key }
    end
    expect(response).to have_http_status(:ok)
  end

  it "denies admin-only API access when the feature is disabled" do
    Setting["plugin_redmine_sudo"] = Setting["plugin_redmine_sudo"].merge(
      "api_sudoer_always_admin" => '0'
    )
    with_settings(rest_api_enabled: '1') do
      get "/users.json", headers: { "X-Redmine-API-Key" => sudoer.api_key }
    end
    expect(response).to have_http_status(:forbidden)
  end

  it "does not elevate a plain user in the same dropped-admin state" do
    sudoer.update_columns(admin: false, sudoer: false)
    with_settings(rest_api_enabled: '1') do
      get "/users.json", headers: { "X-Redmine-API-Key" => sudoer.api_key }
    end
    expect(response).to have_http_status(:forbidden)
  end
end
