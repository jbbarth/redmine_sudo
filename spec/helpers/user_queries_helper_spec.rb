# frozen_string_literal: true

require 'spec_helper'

describe UserQueriesHelper, type: :helper do
  fixtures :users, :email_addresses

  let(:admin_column) { UserQuery.available_columns.find { |c| c.name == :admin } }
  let(:user_7) { User.find(7) }

  describe "#column_value for the :admin column" do
    it "returns 'Yes' for a sudoer who is not currently admin" do
      user_7.update_columns(admin: false, sudoer: true)
      result = helper.column_value(admin_column, user_7, false)
      expect(result).to include(I18n.t(:general_text_Yes))
    end

    it "returns 'Yes' for an admin user" do
      user_7.update_columns(admin: true, sudoer: true)
      result = helper.column_value(admin_column, user_7, true)
      expect(result).to include(I18n.t(:general_text_Yes))
    end

    it "returns 'No' for a non-admin non-sudoer user" do
      user_7.update_columns(admin: false, sudoer: false)
      result = helper.column_value(admin_column, user_7, false)
      expect(result).to include(I18n.t(:general_text_No))
    end
  end
end
