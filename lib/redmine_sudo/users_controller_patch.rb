require_dependency 'users_controller'

class UsersController
  before_filter :require_admin, :except => [:show, :sudo]

  def sudo_toggle
    require_login #should render a 403 if no user found
    render_403 unless User.current.sudoer?
    User.current.update_admin!( !User.current.admin? )
    redirect_to :back
  end
end
