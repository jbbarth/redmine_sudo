# frozen_string_literal: true

require 'spec_helper'

describe UserQuery do
  fixtures :users, :email_addresses

  let(:user_7) { User.find(7) }

  def find_users_with_query(query)
    query.results_scope.to_a
  end

  describe "#sql_for_admin_field (admin filter)" do
    context "filtering for admin = yes (operator '=')" do
      it "includes sudoers who are not currently admin" do
        user_7.update_columns(admin: false, sudoer: true)
        q = UserQuery.new name: '_'
        q.filters = { 'admin' => { operator: '=', values: ['1'] } }
        expect(find_users_with_query(q)).to include(user_7)
      end

      it "includes users who are admin (and sudoer)" do
        user_7.update_columns(admin: true, sudoer: true)
        q = UserQuery.new name: '_'
        q.filters = { 'admin' => { operator: '=', values: ['1'] } }
        expect(find_users_with_query(q)).to include(user_7)
      end

      it "excludes non-admin non-sudoer users" do
        user_7.update_columns(admin: false, sudoer: false)
        q = UserQuery.new name: '_'
        q.filters = { 'admin' => { operator: '=', values: ['1'] } }
        expect(find_users_with_query(q)).not_to include(user_7)
      end
    end

    context "filtering for admin = no (operator '=')" do
      it "excludes sudoers even when not currently admin" do
        user_7.update_columns(admin: false, sudoer: true)
        q = UserQuery.new name: '_'
        q.filters = { 'admin' => { operator: '=', values: ['0'] } }
        expect(find_users_with_query(q)).not_to include(user_7)
      end

      it "excludes admin users" do
        user_7.update_columns(admin: true, sudoer: true)
        q = UserQuery.new name: '_'
        q.filters = { 'admin' => { operator: '=', values: ['0'] } }
        expect(find_users_with_query(q)).not_to include(user_7)
      end

      it "includes non-admin non-sudoer users" do
        user_7.update_columns(admin: false, sudoer: false)
        q = UserQuery.new name: '_'
        q.filters = { 'admin' => { operator: '=', values: ['0'] } }
        expect(find_users_with_query(q)).to include(user_7)
      end
    end
  end
end
