require File.expand_path('../../test_helper', __FILE__)

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
end
