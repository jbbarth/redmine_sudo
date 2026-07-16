# frozen_string_literal: true

module RedmineSudo
  module ApplicationControllerPatch
    def self.prepended(base)
      base.include RedmineSudo::OidcAuthCheck
      base.before_action :enforce_oidc_sudo_restrictions
    end

    # Elevate as part of user_setup, right after User.current has been set, so
    # the elevation reliably runs before controller require_admin filter
    def user_setup
      super
      elevate_api_sudoer
    end

    private

    # Treat a sudoer as admin for the duration of an API request, unless the
    # feature has been explicitly disabled, so API access keeps working
    # regardless of the current web sudo state.
    def elevate_api_sudoer
      return unless api_request?
      return if Setting.plugin_redmine_sudo['api_sudoer_always_admin'] == '0'
      return unless User.current.sudoer?

      User.current.api_sudo_elevated = true
    end

    # If a sudoer is currently admin but their session does not satisfy the
    # configured OIDC conditions, silently revoke their admin rights.
    # This covers the case where an admin logs in via a weaker auth method.
    # Exception: the settings page is never blocked so that a misconfiguration
    # can always be corrected without losing access.
    def enforce_oidc_sudo_restrictions
      return if api_request?
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

ApplicationController.prepend RedmineSudo::ApplicationControllerPatch unless ApplicationController < RedmineSudo::ApplicationControllerPatch
