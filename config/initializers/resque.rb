Resque.redis = "localhost:6379" # default localhost:6379
Resque::Plugins::Status::Hash.expire_in = (60 * 60) # 1he in seconds