if Redmine::VERSION::MAJOR <= 1
  # Rails 2.3
  ActionController::Routing::Routes.draw do |map|
    map.connect 'users/sudo', :controller => 'users', :action => 'sudo'
  end
else
  # Rails 3
  RedmineApp::Application.routes.draw do
    match 'users/sudo', :to => 'users#sudo'
  end
end
