Redis.current = Redis.new(:host => Setting.redis_server, :port => Setting.redis_port)
