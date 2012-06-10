if Redmine::VERSION::MAJOR <= 1
  # Rails 2.3
  ActionController::Routing::Routes.draw do |map|
    map.connect 'sudo/toggle', :controller => 'sudo', :action => 'toggle'
  end
else
  # Rails 3
  RedmineApp::Application.routes.draw do
    match 'sudo/toggle', :to => 'sudo#toggle'
  end
end
