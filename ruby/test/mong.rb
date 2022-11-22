# frozen_string_literal: true

require 'mongoid'

require_relative 'secrets'

Mongoid.configure do |config|
  config.clients.default = {
    uri: MONGO_URI_TEST
  }

  config.log_level = :warn
end

class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :body, type: String
  has_many :comments, dependent: :destroy
end

class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :message, type: String
  belongs_to :post
end

# puts Post.where(title: 'CLI app post title 2')
# puts Post.where(title: 'CLI app post title 2').first
# puts Post.where(title: 'CLI app post title 2').first.attributes
puts Post.where(title: 'CLI app post title 2').first.comments.first.attributes

# Post.create!(title: 'CLI app post title 2', body: 'CLI app post body 2')

# post = Post.create!(title: 'CLI app post title 2', body: 'CLI app post body 2')
# Comment.create!(name: 'CLI app user', message: 'CLI app comment', post: post)
