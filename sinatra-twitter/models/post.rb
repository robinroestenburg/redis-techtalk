class Post

  attr_reader   :id

  attr_accessor :content,
                :user_id,
                :created_at

  class << self

    def all
    end

    def build
    end

  end

end
