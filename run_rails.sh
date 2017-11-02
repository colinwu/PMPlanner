#!/bin/bash
source /usr/local/rvm/environments/ruby-2.3.3@PM-Planner
cd /home/wucolin/apps/PMPlanner/current
env RAILS_ENV=production /usr/local/rvm/gems/ruby-2.3.3@PM-Planner/bin/rails r $1 $2 $3 $4 $5

