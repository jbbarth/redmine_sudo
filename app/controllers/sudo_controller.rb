class SudoController < ApplicationController
  def toggle
    require_login #should render a 403 if no user found
    render_403 unless User.current.sudoer?
    User.current.update_admin!( !User.current.admin? )
    redirect_back_or_default :controller => "my", :action => "page"
  end
end
