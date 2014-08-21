require "spec_helper"

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

describe "User" do
  it "should user gets correct sudoer at creation" do
    user = User.generate(:admin => true)
    user.sudoer?.should == true
    user = User.generate(:admin => false)
    user.sudoer?.should == false
  end

  it "should user keeps sudoer on update if he should" do
    user = User.generate(:admin => true)
    user.update_admin!(false)
    user.reload.sudoer?.should == true
    #doesn't change #admin, so #sudoer doesn't change
    user.update_attribute(:firstname, "John")
    user.reload.sudoer?.should == true
  end

  it "should user gets correct sudoer when updating admin boolean" do
    user = User.generate(:admin => true)
    #updates #admin, so #sudoer should be updated accordingly
    user.update_attribute(:admin, false)
    user.reload.sudoer?.should == false
    user.update_attribute(:admin, true)
    user.reload.sudoer?.should == true
  end

  it "should #update_admin! sets a new updated_on date after admin changed" do
    user = User.generate(:admin => true)
    user.update_attribute(:updated_on, nil)
    user.reload.updated_on.should == nil
    user.update_admin!(false)
    assert_not_nil user.reload.updated_on
  end
end
