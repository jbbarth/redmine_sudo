# frozen_string_literal: true

module RedmineSudo
  module ApplicationControllerPatch
    def self.included(base)
      base.include RedmineSudo::OidcAuthCheck
      base.before_action :enforce_oidc_sudo_restrictions
    end

    private

    # If a sudoer is currently admin but their session does not satisfy the
    # configured OIDC conditions, silently revoke their admin rights.
    # This covers the case where an admin logs in via a weaker auth method.
    # Exception: the settings page is never blocked so that a misconfiguration
    # can always be corrected without losing access.
    def enforce_oidc_sudo_restrictions
      return unless User.current.logged?
      return unless User.current.admin?
      return unless User.current.sudoer?
      return unless oidc_restriction_active?
      return if oidc_conditions_met?
      return if controller_name == 'settings' && action_name == 'plugin' && params[:id] == 'redmine_sudo'

      User.current.update_admin!(false)
    end
  end
end

ApplicationController.include RedmineSudo::ApplicationControllerPatch unless ApplicationController < RedmineSudo::ApplicationControllerPatch
