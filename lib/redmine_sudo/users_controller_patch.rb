require_dependency 'users_controller'

class UsersController
  before_filter :require_admin, :except => [:show, :sudo]

  def sudo
    require_login #should render a 403 if no user found
    user = User.current
    render_403 unless user.sudoer?
    new_value = !user.admin?
    User.update_all({:admin => !user.admin?}, {:id => user.id})
    redirect_to :back
  end
end
