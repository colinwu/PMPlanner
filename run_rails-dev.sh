#!/bin/bash
source /usr/local/rvm/environments/ruby-2.4.1@PM-Planner-Rails5
source /home/wucolin/.profile
cd /home/wucolin/src/PMPlanner
env RAILS_ENV=development /usr/local/rvm/gems/ruby-2.4.1@PM-Planner-Rails5/bin/rails r $1 $2 $3 $4 $5

