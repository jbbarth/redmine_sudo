require 'spec_helper'

describe UsersController, type: :controller do
  render_views
  fixtures :users

  let!(:user_7) { User.find(7) }

  before do
    @controller = UsersController.new
    @request = ActionDispatch::TestRequest.create
    @response = ActionDispatch::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1 # permissions admin
  end

  describe "POST update" do
    it "gives both sudoer and admin roles when selecting the option in user form" do
      user_7.update_attribute(:admin, false)
      expect(user_7).to_not be_admin
      expect(user_7).to_not be_sudoer

      patch :update, :params => { :id => 7, :user => { admin: '1', mail: "test7@example.net" } }

      user_7.reload
      expect(user_7).to be_admin
      expect(user_7).to be_sudoer
    end

    it "removes both sudoer and admin roles when deselecting the option in user form" do
      user_7.update_attribute(:admin, true)
      expect(user_7).to be_admin
      expect(user_7).to be_sudoer

      patch :update, :params => { :id => 7, :user => { admin: '0', mail: "test7@example.net" } }

      user_7.reload
      expect(user_7).to_not be_admin
      expect(user_7).to_not be_sudoer
    end

    it "removes both sudoer and admin roles even when user is not currently admin" do
      user_7.update(admin: false, sudoer: true)
      expect(user_7).to_not be_admin
      expect(user_7).to be_sudoer

      patch :update, :params => { :id => 7, :user => { admin: '0', mail: "test7@example.net" } }

      user_7.reload
      expect(user_7).to_not be_admin
      expect(user_7).to_not be_sudoer
    end
  end

end
