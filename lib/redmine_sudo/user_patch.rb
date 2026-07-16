require_dependency 'project' # see: http://www.redmine.org/issues/11035
require_dependency 'principal'
require_dependency 'user'

module RedmineSudo::UserPatch
  def update_sudoer
    if new_record? || self.admin || admin_changed?
      self.sudoer = self.admin
    end
    true
  end

  def update_admin!(value)
    User.where(:id => self.id).update_all(:admin => value)
    User.where(:id => self.id).update_all(:updated_on => Time.now)
  end

  # Per-request, in-memory admin elevation for API requests
  # It lets a sudoer who dropped admin rights in the web UI keep full rights over the API.
  module ApiElevation
    def admin?
      return true if @api_sudo_elevated

      super
    end
  end
end

class User < Principal
  prepend RedmineSudo::UserPatch::ApiElevation
  include RedmineSudo::UserPatch
  attr_accessor :api_sudo_elevated
  before_save :update_sudoer
end

class AnonymousUser < User
  def sudoer?
    false
  end
end
