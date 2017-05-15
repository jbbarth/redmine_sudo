require File.expand_path('../../rails_helper', __FILE__)

describe 'Sudo link toggle', js: true do
  let(:admin) { FactoryGirl.create(:admin, login: 'admin', department: Department.new) }

  before do
    login_user(admin.login, 'foo')
  end

  it 'should toggle sudo rights' do
    assert admin.reload.admin?
    assert admin.reload.sudoer?

    page.find('.sudo').click
    assert !admin.reload.admin?

    page.find('.sudo').click
    assert admin.reload.admin?
  end
end