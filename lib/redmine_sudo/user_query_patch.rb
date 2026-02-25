# frozen_string_literal: true

require_dependency 'user_query'

module RedmineSudo
  module UserQueryPatch
    # Override to include sudoers in the admin filter:
    # - "Administrateur = Oui" returns users where admin=true OR sudoer=true
    # - "Administrateur = Non" returns users where admin=false AND sudoer=false
    def sql_for_admin_field(field, operator, value)
      return unless value = value.first

      true_value = operator == '=' ? '1' : '0'
      if value.to_s == true_value
        "(#{User.table_name}.admin = #{self.class.connection.quoted_true}" \
          " OR #{User.table_name}.sudoer = #{self.class.connection.quoted_true})"
      else
        "(#{User.table_name}.admin = #{self.class.connection.quoted_false}" \
          " AND #{User.table_name}.sudoer = #{self.class.connection.quoted_false})"
      end
    end
  end
end
UserQuery.prepend RedmineSudo::UserQueryPatch
