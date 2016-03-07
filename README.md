# Coconuts

It's a content management platform in Ruby on Rails.


##   Part 0 : Environment setup problem
1. bundle install problem: mysql.h is missing
    solve : http://stackoverflow.com/questions/5919727/bundle-install-problem-mysql-h-is-missing



##   Part 1 : Server boot-up problem
1. Nginx not auto start-up problem
   => port 80 blocked by apache2 by default, see 'ps ax | grep apache2'
   => modify /etc/apache2/ports.conf and delete /etc/apache2/sites-enabled/000-default
   => 'sudo update-rc.d nginx defaults' to add service to auto-start list
   => if do not want to reboot, kill apache process by 'sudo kill -9 <pid>' then 'sudo service nginx start'

2. Sidekiq auto start-up # (X: not yet success ...)
   => download sidekiq.conf & workers.conf from 'https://github.com/mperham/sidekiq/tree/master/examples/upstart'
   => move them to '/etc/init.d/sidekiq' & '/etc/init.d/workers', then 'sudo update-rc.d _____ defaults'



##   Part 2 : Background tasks (Sidekiq + Redis + Whenever)
sidekiq       # start sidekiq, or 'bundle exec sidekiq ... -L log/sidekiq.log &', add 'xvfb-run' in front while at cloud server, see part 3
whenever -i   # reload scheduled task settings
crontab -e    # edit unix cron-tab for scheduled tasks
config in config/sidekiq.yml & config/schedule.rb

  1. Job queue but not processed => sidekiq haven't start.
  2. Job failed => user password error / 
                   wordpress json-api create-post not enabled / 
                   db host not grant access /
  3. Redis-server has not enabled / check by 'redis-cli ping'
  4. try flushall redis-cli keys, or directly edit crontab, remove unused one.
  5. add in config/schedule.rb => set :job_template, "bash -l -i -c ':job'"
  6. don't leave any 'puts' in background script, will cause error while no login shell.



##   Part 3 : About Capybara, the pseudo browser

#### QT packages needed
sudo apt-get install libqt4-dev libqtwebkit-dev
#### in cloud server, for solving no display session problem
sudo apt-get install xvfb libicu48 
#### than add this lin 'export DISPLAY=localhost:1.0' in ~/.bash_profile and start any command need display session by 'xvfb-run'
Ex: 'xvfb-run bundle exec sidekiq ... -L log/sidekiq.log &'



##   Part 4 : Mongoid & Redis Database backup and feedback
####[MONGOID database]
[Dump selected database in current path]
mongodump --db <db_name>

[Drop database to clean all]
mongo <db_name> --eval "db.dropDatabase()"

[Recover selected database from assigned path]
mongorestore --db <db_name> ./dump/<db_name>/


[REDIS database]
Dump redis all (need Gem redis-dump)
redis-dump > ./dump/<db_name>_redis.json

Clean all
redis-cli flushall

Restore from json
cat ./dump/<db_name>_redis.json | redis-load

[Redis on MAC]
To have launchd start redis at login:
    ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
Then to load redis now:
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
Or, if you don't want/need launchctl, you can just run:
    redis-server /usr/local/etc/redis.conf

