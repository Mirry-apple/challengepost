require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection('sqlite3:db/development.db') if development?

class User < ActiveRecord::Base
  has_secure_password
  validates :name, uniqueness: true
  has_many :posts
  has_many :post_tags
  has_many :likes
  has_many :comments
  has_many :likesposts, through: :likes, source: :post
  has_many :commentsposts, through: :comments, source: :post
  # イイねした投稿を取得するための真の宛先
end

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  has_many :likes
  has_many :posttags
  has_many :tags, through: :posttags
  has_many :commentsusers, through: :comments, source: :user
  has_many :likesusers, through: :likes, source: :user
end

class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
end

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
end

class Tag < ActiveRecord::Base
  has_many :posts, through: :posttags
  has_many :posttags
  has_many :tagpost, through: :posttags, source: :post
end

class Posttag < ActiveRecord::Base
  belongs_to :post
  belongs_to :tag
end
