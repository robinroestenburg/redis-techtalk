class Post

  attr_accessor :id, :content, :created_at, :user_id

  class << self

    def create(content, user)
      # Retrieve the next identifier
      post_id = redis.incr('post:uid')

      # Store the data of the post
      redis.hset("post:#{post_id}", "content",    "#{content}")
      redis.hset("post:#{post_id}", "created_at", "#{Time.now.to_s}")
      redis.hset("post:#{post_id}", "user_id",    "#{user.id}")

      # Add the post to the main timeline

      # Add the post to the users timeline
      redis.lpush("user:#{user.id}:posts",    "#{post_id}")
      redis.lpush("user:#{user.id}:timeline", "#{post_id}")

      # Add the post to the timeline of all your followers
      user.followers.each do |follower|
        redis.lpush("user:#{follower.id}:timeline", "#{post_id}")
      end

      find(post_id)
    end

    def find(post_id)
      if redis.exists("post:#{post_id}")
        post            = Post.new
        post.id         = post_id
        post.content    = redis.hget("post:#{post_id}", "content")
        post.created_at = Time.parse(redis.hget("post:#{post_id}", "created_at"))
        post.user_id    = redis.hget("post:#{post_id}", "user_id")
        post
      end
    end

  end

  def user
    User.find(user_id)
  end
end
