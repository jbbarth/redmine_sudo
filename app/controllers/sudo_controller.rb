class SudoController < ApplicationController
  def toggle
    require_login #should render a 403 if no user found
    render_403 unless User.current.sudoer?
    User.current.update_admin!( !User.current.admin? )
    redirect_to :back
  end
end
