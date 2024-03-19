require_dependency 'users_controller'

module RedmineSudo
  module UsersControllerPatch
    extend ActiveSupport::Concern

    def update_sudoer
      if @user.present? && params[:user][:admin] == '0'
        @user.admin = false
        @user.sudoer = false
      end
    end

  end
end

class UsersController
  include RedmineSudo::UsersControllerPatch
  append_before_action :update_sudoer, :only => [:update]
end
