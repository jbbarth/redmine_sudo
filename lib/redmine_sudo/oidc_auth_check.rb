# frozen_string_literal: true

module RedmineSudo
  module OidcAuthCheck
    def oidc_restriction_active?
      settings = Setting.plugin_redmine_sudo
      settings['require_oidc_for_sudo'] == '1' ||
        settings['required_oidc_auth_level'].to_s.strip.present?
    end

    def oidc_conditions_met?
      return false unless session[:logged_in_with_oidc]

      required_level = Setting.plugin_redmine_sudo['required_oidc_auth_level'].to_s.strip
      return true if required_level.blank?

      session[:oidc_auth_level].to_s == required_level
    end
  end
end
