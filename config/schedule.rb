# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# solve logout then cron died problem, http://blog.scoutapp.com/articles/2010/09/07/rvm-and-cron-in-production#dsq-comment-138101845
set :job_template, "bash -l -i -c ':job'"
set :output, "~/cron_log.log"

#Many shortcuts available: :hour, :day, :month, :year, :reboot
every 15.minute do
  #runner "MinuteWorker.perform_async"
  runner "QuarterWorker.perform_async"
  #rake "wordpress:update2beta"
end

every 1.hour do
  #runner "HourlyWorker.perform_async"
  rake "recommend:update"
  rake "bullet:score_curate"
end

#every :day, :at => '03:00am' do
#  rake "bgjob:stop"
#end
#every :day, :at => '03:30am' do
#  rake "dev:rebuild"
#end
#every :day, :at => '04:00am' do
#  rake "bgjob:start"
#end

every :day, :at => '04:30am' do
  runner "DailyWorker.perform_async"
end

#every 1.day, :at => '5:00 am' do
#  rake "-s sitemap:refresh"
#end
