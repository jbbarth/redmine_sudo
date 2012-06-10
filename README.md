# Redmine Sudo plugin

This plugin allows administrators of a redmine instance to change their rights temporarily and navigate as if they were normal users. Then they can take back their administrator rights only when needed. It's the same idea as "sudo" in Linux/Unix operating systems, you don't need to be root all the time.

## Compatibility

This plugin should work with any 1.x version, but **not** 2.x for the moment.

## Installation

See: http://www.redmine.org/projects/redmine/wiki/Plugins

Basically you just have to:

* drop the plugin in the "vendor/plugins/" directory
* run `rake db:migrate:all`
* restart your redmine instance
