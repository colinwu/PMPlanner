#!/bin/bash
source /home/wucolin/.rvm/environments/ruby-2.2.4@PMPlanner

cd /home/wucolin/apps/PMPlanner/current
env RAILS_ENV=production ~/bin/rails r $1 $2 $3 $4 $5

