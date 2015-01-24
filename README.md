Redmine Sudo plugin
===================

This plugin allows administrators of a redmine instance to change their rights temporarily and navigate as if they were normal users. Then they can take back their administrator rights only when needed. It's the same idea as "sudo" in Linux/Unix operating systems, you don't need to be root all the time.

The plugin also allows to define some CSS that will only be included when you're administrator, so that you can always obviously know your status. See below the 3rd screenshot, the proposed styles change the header background colors to red.

Screenshot
----------

Here's a screenshot when you're a standard user:

![redmine_sudo screenshot](http://jbbarth.com/screenshots/redmine_sudo_1.png)

If you click on it you become administrator:

![redmine_sudo screenshot](http://jbbarth.com/screenshots/redmine_sudo_2.png)

The admin section lets you define the title of the links and some CSS styles that will be applied only when admin:

![redmine_sudo screenshot](http://jbbarth.com/screenshots/redmine_sudo_3.png)

Installation
------------

See: http://www.redmine.org/projects/redmine/wiki/Plugins

**plugin requirement:**
* this plugin requires the plugin [redmine_base_deface](https://github.com/jbbarth/redmine_base_deface) to be installed!
* make sure you got it installed or install it before installing `redmine_sudo` plugin

Then you basically just have to:

* drop the plugin in the "plugins/" directory
* run `rake redmine:plugins:migrate`
* restart your redmine instance

Compatibility
-------------

This plugin only works with Redmine > 2.1.0. If you have any issue, don't forget to mention the Redmine version you're using.

Contribute
----------

If you like this plugin, it's a good idea to contribute :
* by giving feed back on what is cool, what should be improved
* by reporting bugs : you can open issues directly on github
* by forking it and sending pull request if you have a patch or a feature you want to implement
