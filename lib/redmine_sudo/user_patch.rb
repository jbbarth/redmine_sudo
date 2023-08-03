require_dependency 'project' # see: http://www.redmine.org/issues/11035
require_dependency 'principal'
require_dependency 'user'

module RedmineSudo::UserPatch
  def update_sudoer
    if new_record? || admin? || admin_changed?
      self.sudoer = self.admin
    end
    true
  end

  def update_admin!(value)
    User.where(:id => self.id).update_all(:admin => value)
    User.where(:id => self.id).update_all(:updated_on => Time.now)
  end
end

class User
  prepend RedmineSudo::UserPatch
  before_save :update_sudoer
end
