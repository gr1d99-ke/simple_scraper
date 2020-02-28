module RedisService
  class << self
    def call
      yield Redis.current if block_given?
      Redis.current
    end
  end
end
