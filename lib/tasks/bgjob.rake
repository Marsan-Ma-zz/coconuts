#encoding: utf-8  

namespace :bgjob do
  task :restart => ["bgjob:stop", "bgjob:start"]

  task :stop => :environment do
    system("kill $(ps aux | grep '[s]idekiq' | awk '{print $2}')")
    system("kill $(ps aux | grep '[s]idekiq' | awk '{print $2}')")
    system("kill $(ps aux | grep '[X]vfb' | awk '{print $2}')")
  end

  task :start => :environment do
    system("xvfb-run bundle exec sidekiq -e production ... -L log/sidekiq.log &")
  end

end
