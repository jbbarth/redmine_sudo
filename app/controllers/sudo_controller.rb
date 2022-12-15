class SudoController < ApplicationController
  def toggle
    require_login #should render a 403 if no user found
    if User.current.sudoer?
      User.current.update_admin!( !User.current.admin? )

      params[:back_url] = url_for(request.referer) if request.referer.present?
      redirect_back_or_default :controller => "my", :action => "page"
    else
      render_403
    end
  end
end
