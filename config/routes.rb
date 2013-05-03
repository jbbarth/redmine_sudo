RedmineApp::Application.routes.draw do
  match 'sudo/toggle', :to => 'sudo#toggle', :as => 'sudo_toggle'
end
