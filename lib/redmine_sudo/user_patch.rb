require_dependency 'principal'
require_dependency 'user'

class User
  before_save :update_sudoer

  def update_sudoer
    if new_record? || admin? || admin_changed?
      self.sudoer = self.admin
    end
    true
  end
end
