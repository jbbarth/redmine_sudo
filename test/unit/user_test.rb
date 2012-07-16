require File.expand_path('../../test_helper', __FILE__)

# redmine 2.x doesn't use object_daddy anymore
unless User.respond_to?(:generate)
  def User.generate(attributes = {})
    @generated_user_login ||= 'user0'
    @generated_user_login.succ!
    user = User.new(attributes)
    user.login = @generated_user_login if user.login.blank?
    user.mail = "#{@generated_user_login}@example.com" if user.mail.blank?
    user.firstname = "Bob" if user.firstname.blank?
    user.lastname = "Doe" if user.lastname.blank?
    yield user if block_given?
    user.admin = true if attributes[:admin]
    user.save!
    user
  end
end

class UserTest < ActiveSupport::TestCase
  test 'user gets correct sudoer at creation' do
    user = User.generate(:admin => true)
    assert_equal true, user.sudoer?
    user = User.generate(:admin => false)
    assert_equal false, user.sudoer?
  end

  test 'user keeps sudoer on update if he should' do
    user = User.generate(:admin => true)
    user.update_admin!(false)
    assert_equal true, user.reload.sudoer?
    #doesn't change #admin, so #sudoer doesn't change
    user.update_attribute(:firstname, "John")
    assert_equal true, user.reload.sudoer?
  end

  test 'user gets correct sudoer when updating admin boolean' do
    user = User.generate(:admin => true)
    #updates #admin, so #sudoer should be updated accordingly
    user.update_attribute(:admin, false)
    assert_equal false, user.reload.sudoer?
    user.update_attribute(:admin, true)
    assert_equal true, user.reload.sudoer?
  end

  test '#update_admin! sets a new updated_on date after admin changed' do
    user = User.generate(:admin => true)
    user.update_attribute(:updated_on, nil)
    assert_equal nil, user.reload.updated_on
    user.update_admin!(false)
    assert_not_nil user.reload.updated_on
  end
end
