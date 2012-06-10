ActionController::Routing::Routes.draw do |map|
  map.connect 'users/sudo', :controller => 'users', :action => 'sudo'
end
