class SudoController < ApplicationController
  def toggle
    require_login # should render a 403 if no user found
    if User.current.sudoer?
      if !User.current.admin? && oidc_restriction_active? && !oidc_conditions_met?
        custom_message = Setting.plugin_redmine_sudo['oidc_error_message'].to_s.strip
        flash[:error] = custom_message.presence || l(:error_sudo_requires_stronger_auth)
        redirect_back_or_default :controller => "my", :action => "page"
        return
      end

      User.current.update_admin!(!User.current.admin?)

      params[:back_url] = url_for(request.referer) if request.referer.present?
      redirect_back_or_default :controller => "my", :action => "page"
    else
      render_403
    end
  end

end
