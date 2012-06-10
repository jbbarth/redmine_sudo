# Redmine Sudo plugin

This plugin allows administrators of a redmine instance to change their rights temporarily and navigate as if they were normal users. Then they can take back their administrator rights only when needed. It's the same idea as "sudo" in Linux/Unix operating systems, you don't need to be root all the time.

## Compatibility

This plugin should work with any 1.x and 2.x version. If you have any issue, don't forget to mention the Redmine version you're using.

## Installation

See: http://www.redmine.org/projects/redmine/wiki/Plugins

Basically you just have to:

* drop the plugin in the "vendor/plugins/" directory (Redmine 1.x) or "plugins/" directory (Redmine 2.x)
* run `rake db:migrate:all` (Redmine 1.x) or `rake redmine:plugins:migrate` (Redmine 2.x)
* restart your redmine instance
