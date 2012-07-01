require 'redmine'

if Redmine::VERSION::MAJOR <= 1
  # Rails 2.3
  require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
  Engines::Testing.set_fixture_path
else
  # Rails 3
  require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
end
