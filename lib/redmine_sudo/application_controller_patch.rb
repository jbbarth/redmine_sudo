# frozen_string_literal: true

# Elevated admin rights live in the browser session and nowhere else. Nothing
# in here ever writes the `admin` column, so one session can neither elevate
# nor demote another, and any request that carries no session -- REST API,
# OAuth, atom key, rake task, background job -- always runs with the user's
# plain, unelevated rights.
#
# This module also manages Redmine core's own SudoMode session lifecycle for
# the elevated state: it drops the elevation once that session expires, and
# slides the session forward on any confirmed admin action so genuine ongoing
# work doesn't expire mid task.
module RedmineSudo
  module ApplicationControllerPatch
    extend ActiveSupport::Concern

    # Holds the id of the user who elevated in this session. Storing the id
    # rather than a boolean means the key can never elevate a different user
    # if the session outlives a re-login.
    SUDO_ADMIN_SESSION_KEY = :sudo_admin_user_id

    prepended do
      before_action :enforce_sudo_grace_timeout
    end

    # Marks the request's own User instance as elevated, once the user is resolved.
    #
    # This deliberately hooks `user_setup` and not `find_current_user`: how the
    # user got resolved is the business of whichever controller's lookup ran
    # (a controller may well resolve the session of a JSON request itself), but
    # the elevation only depends on what the session says about the resolved
    # user. Only an interactive session login sets `session[:user_id]`.
    def user_setup
      super
      user = User.current
      user.sudo_session_admin = true if user.logged? && sudo_admin_elevated?(user)
    end

    # Slides Redmine core's SudoMode session on any `require_admin`-gated
    # action, not just the handful of controllers (Users, Roles, Settings,
    # Groups, ...) that core itself additionally wraps in `require_sudo_mode`.
    #
    # Without this, working continuously in an "auxiliary" admin screen that
    # is only gated by `require_admin` (Trackers, IssueStatuses, Enumerations,
    # CustomFields, Workflows, ...) never touches `Redmine::SudoMode.active?`,
    # so the sudo timestamp goes stale after `sudo_mode_timeout` minutes and
    # `enforce_sudo_grace_timeout` below auto-drops admin mid-task even though
    # the user never stopped working.
    #
    # `Redmine::SudoMode.active?` only reads the current session state and
    # marks it "used" as a side effect (see
    # Redmine::SudoMode::Controller#sudo_mode around_action) — unlike
    # `require_sudo_mode`, it never itself demands a password. So calling it
    # here can only slide an already-valid session forward; it can never
    # force a re-prompt for actions that didn't require one before.
    def require_admin
      result = super
      Redmine::SudoMode.active? if result
      result
    end

    private

    # True when this request may act on the elevation stored in this session.
    #
    # The session must be the one that authenticated the user. Core empties
    # the session of an API request, so an API key, atom key or OAuth token
    # can never inherit an elevation even when the client also happens to send
    # the session cookie (a browser calling `/users.json?key=...` does). A
    # controller that keeps the session on API requests has to drop it when
    # API credentials are supplied.
    def sudo_admin_elevated?(user)
      return false unless session[:user_id] == user.id
      return false unless session[SUDO_ADMIN_SESSION_KEY] == user.id
      # redmine_pretend impersonation: the impersonated user must never
      # inherit the impersonator's elevation.
      return false if session[:real_user_id].present?
      # With core sudo mode disabled there is no window to expire against, so
      # the elevation simply lasts for the whole session.
      return true unless Redmine::SudoMode.enabled?

      sudo_timestamp_valid?
    end

    def sudo_admin_session_active?
      session[SUDO_ADMIN_SESSION_KEY].present?
    end

    def elevate_sudo_admin!
      session[SUDO_ADMIN_SESSION_KEY] = User.current.id
      User.current.sudo_session_admin = true
    end

    # Drops the elevation and forces the core sudo session to be considered
    # expired, so the next sudo-gated action (including a future Become Admin)
    # requires a fresh password re-entry.
    def drop_sudo_admin!
      session.delete(SUDO_ADMIN_SESSION_KEY)
      session[:sudo_timestamp] = 0
      User.current.sudo_session_admin = false
    end

    # Read-only check — `sudo_timestamp_valid?` is a plain comparison with no
    # side effects, unlike `Redmine::SudoMode.active?`/`.active!` which mark
    # the session as "used" and cause it to be silently refreshed. This keeps
    # ordinary browsing from extending the window; only genuine admin actions
    # (via `require_admin` above, core's own `require_sudo_mode`, or our own
    # Become Admin) do that.
    #
    # `user_setup` has already refused to elevate by the time this runs, so
    # all that is left here is clearing the stale session key and recording
    # the expiry.
    def enforce_sudo_grace_timeout
      return unless sudo_admin_session_active?
      return unless Redmine::SudoMode.enabled?
      return if sudo_timestamp_valid?

      user = User.current
      drop_sudo_admin!
      SecurityAuditLog.log(
        action: 'sudo_expired',
        entity: user,
        entity_name: user.login,
        remote_ip: request.remote_ip
      )
    end
  end
end

