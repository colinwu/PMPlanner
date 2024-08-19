#!/bin/bash
source /usr/local/rvm/environments/ruby-3.0.0@PM-Planner-Rails7
source /home/wucolin/.profile
cd /home/wucolin/apps/PMPlanner-new/current
env RAILS_ENV=production /usr/local/rvm/gems/ruby-3.0.0@PM-Planner-Rails7/bin/rails r $1 $2 $3 $4 $5

