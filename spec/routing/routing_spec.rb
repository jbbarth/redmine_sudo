require File.expand_path('../../rails_helper', __FILE__)

describe 'Sudo toggle link' do
  it 'should route to sudo#toggle' do
    expect(get: '/sudo/toggle').to route_to(controller: 'sudo', action: 'toggle')
  end
end

