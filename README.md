# Chef recipes for setting up RJC website

Based on [Flatstack's Rails Chef recipes](https://github.com/fs/chef-rails-cookbooks).

## Quick start

* Bootstrap local environment with `script/bootstrap`
* Setup key based authentication to the target host for example with `ssh-copy-id`
* Prepare target server with `script/prepare root@HOSTNAME`
* Customize `nodes/hostname.json`
* Apply configuration to target host with `script/cook user@HOSTNAME`
