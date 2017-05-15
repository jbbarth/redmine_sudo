require File.expand_path('../../rails_helper', __FILE__)

describe 'При нажатии кнопки смены пользователя', js: true do
  let(:department) { create(:department) }
  let!(:user) { create(:admin, department: department) }
  let(:become_admin) { Setting.plugin_redmine_sudo['become_admin'] }
  let(:become_user) { Setting.plugin_redmine_sudo['become_user'] }
  before do
    login_user(user.login, 'foo')
  end

  it 'меняются права пользователя с админа на юзера и обратно' do
    expect(page).to have_css('.sudo', text: become_user)
    click_link(become_user)
    expect(page).to have_css('.sudo', text: become_admin)
    click_link(become_admin)
    expect(page).to have_css('.sudo', text: become_user)
  end
end
