#!/bin/bash
source /usr/local/rvm/environments/ruby-2.4.1@PM-Planner
source /home/wucolin/.profile
cd /home/wucolin/apps/PMPlanner/current
env RAILS_ENV=production /usr/local/rvm/gems/ruby-2.4.1@PM-Planner/bin/rails r $1 $2 $3 $4 $5

