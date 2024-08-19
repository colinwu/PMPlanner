#!/bin/bash
source /usr/local/rvm/environments/ruby-3.0.0@PM-Planner-Rails7
source /home/wucolin/.profile
cd /home/wucolin/src/PMPlanner
env RAILS_ENV=development /usr/local/rvm/gems/ruby-3.0.0@PM-Planner-Rails7/bin/rails r $1 $2 $3 $4 $5

