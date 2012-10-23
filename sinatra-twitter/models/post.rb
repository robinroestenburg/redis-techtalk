class Post

  attr_accessor :id, :content, :created_at, :user_id

  class << self

    def create(content, user)
      # Retrieve the next identifier

      # Store the data of the post

      # Add the post to the users timeline

      # Add the post to the timeline of all your followers

      # Retrieve the Post object
      find(0)
    end

    def find(post_id)
    end

  end

  def user
    User.find(user_id)
  end
end
