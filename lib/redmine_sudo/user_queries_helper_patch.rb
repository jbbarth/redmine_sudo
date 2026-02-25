# frozen_string_literal: true

require_dependency 'user_queries_helper'

module RedmineSudo
  module UserQueriesHelperPatch
    # Show admin column as "Yes" for sudoers even when they're not currently admin
    def column_value(column, object, value)
      if object.is_a?(User) && column.name == :admin
        l(object.admin? || object.sudoer? ? :general_text_Yes : :general_text_No)
      else
        super
      end
    end
  end
end
UserQueriesHelper.prepend RedmineSudo::UserQueriesHelperPatch