class User
  attr_accessor :id, :fullname, :username, :emailaddress, :password

  class << self

    def find_by_username(username)
      if user_id = redis.get("user:username:#{username}")
        User.find(user_id)
      end
    end

    def find(user_id)
      if redis.exists("user:#{user_id}")
        user                 = User.new
        user.id              = user_id
        user.emailaddress    = redis.hget("user:#{user_id}", "emailadress")
        user.username        = redis.hget("user:#{user_id}", "username")
        user.fullname        = redis.hget("user:#{user_id}", "fullname")
        user.password        = redis.hget("user:#{user_id}", "password")
        user
      end
    end

    def all(page = 1)
      from = (page-1) * 50
      to   = page * 50

      redis.lrange("users", from, to).map do |user_id|
        User.find(user_id)
      end
    end

    def create(username, password, emailaddress, fullname)
      user_id = redis.incr("user:uid")

      # Create the user
      redis.hset("user:#{user_id}", "fullname",     fullname)
      redis.hset("user:#{user_id}", "emailaddress", emailaddress)
      redis.hset("user:#{user_id}", "username",     username)
      redis.hset("user:#{user_id}", "password",     password)

      # Add the user to the head of all users
      redis.lpush("users", user_id)

      # Register the username -> id mapping
      redis.set("user:username:#{username}", user_id)

      find(user_id)
    end

  end

  def ==(other)
    @id.to_i == other.id.to_i
  end

  def timeline(page = 1)
    from = (page-1) * 50
    to   = page * 50

    redis.lrange("user:#{@id}:timeline", from, to).map do |post_id|
      Post.find(post_id)
    end
  end

  def posts(page = 1)
    from = (page-1) * 50
    to   = page * 50

    redis.lrange("user:#{@id}:posts", from, to).map do |post_id|
      Post.find(post_id)
    end
  end

  def number_of_tweets
    redis.llen("user:#{@id}:posts")
  end

  def number_of_followees
    redis.scard("user:#{@id}:followees")
  end

  def number_of_followers
    redis.scard("user:#{@id}:followers")
  end

  def follow(user)
    unless user.id == @id
      redis.sadd("user:#{@id}:followees", user.id)
      redis.sadd("user:#{user.id}:followers", @id)
    end
  end

  def unfollow(user)
    redis.srem("user:#{@id}:followees", user.id)
    redis.srem("user:#{user.id}:followers", @id)
  end

  def following?(user)
    if user == self
      true
    else
      redis.sismember("user:#{@id}:followees", user.id)
    end
  end

  def followers
    redis.smembers("user:#{@id}:followers").map do |user_id|
      User.find(user_id)
    end
  end

  def followees
    redis.smembers("user:#{@id}:followees").map do |user_id|
      User.find(user_id)
    end
  end

end
