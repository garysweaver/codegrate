#!/bin/bash

# fail on error. this is important because you don't want to install newer rails in an older gemset, etc.
set -e

# check for rvm
hash rvm

rvm install ruby-1.9.2-p180
rvm use ruby-1.9.2-p180
rvm gemset create rails31
rvm use ruby-1.9.2-p180@rails31
gem install rails -v 3.1.0.rc5 --no-ri --no-rdoc
rvm info
