require File.expand_path("../../test_helper", __FILE__)

class SudoTest < ActionController::IntegrationTest
  fixtures :users, :roles

  context "toggle link" do
    should "route to sudo#toggle" do
      assert_routing(
        { :method => :get, :path => "/sudo/toggle" },
        { :controller => "sudo", :action => "toggle" }
      )
    end

    should "toggle sudo rights" do
      user = User.find_by_login("admin")
      log_user("admin", "admin")

      assert user.reload.admin?

      get "sudo/toggle?back_url=/my/page"
      assert_redirected_to "/my/page"
      assert !user.reload.admin?

      get "sudo/toggle?back_url=/my/page"
      assert_redirected_to "/my/page"
      assert user.reload.admin?
    end 
  end
end
