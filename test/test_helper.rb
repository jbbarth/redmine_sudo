rails2_helper = File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
rails3_helper = File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

if File.exists?(rails2_helper)
  # Rails 2.3
  require rails2_helper
  Engines::Testing.set_fixture_path
else
  # Rails 3
  require rails3_helper
end
