require_dependency 'users_controller'

class UsersController
  before_filter :require_admin, :except => [:show, :sudo]

  def sudo
    require_login #should render a 403 if no user found
    render_403 unless User.current.sudoer?
    if User.current.admin?
      User.current.update_attribute(:admin, false)
    else
      User.current.update_attribute(:admin, true)
    end
    redirect_to :back
  end
end
