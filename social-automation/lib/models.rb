# frozen_string_literal: true

require 'mongoid'

require_relative 'secrets'

Mongoid.configure do |config|
  config.clients.default = {
    uri: MONGO_URI_ALI
  }

  config.log_level = :warn
end

class State
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :page_url, type: String
  field :cities_page_url, type: String
  field :users_page_url, type: String
  field :total_users, type: Integer
  field :total_cities, type: Integer
  has_many :cities, class_name: 'City'
  has_many :members
  validates_uniqueness_of :name, :page_url, :cities_page_url, :users_page_url
  validates :name, :page_url, :cities_page_url, :users_page_url, :total_users, :total_cities, presence: true
end

class City
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :page_url, type: String
  field :users_page_url, type: String
  field :total_users, type: Integer
  field :pages_to_scrape, type: Integer
  field :pages_scraped, type: Integer
  field :scraped_all_pages, type: Boolean
  has_many :members
  belongs_to :state
  validates_uniqueness_of :page_url, :users_page_url
  validates :name, :page_url, :users_page_url, :total_users, :pages_to_scrape, :pages_scraped, :scraped_all_pages, presence: true
end

class Member
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uid, type: String
  field :age, type: Integer
  field :gender, type: String
  field :username, type: String
  field :orientation, type: String
  field :style, type: String
  field :interests, type: Array
  field :curiosities, type: Array
  field :looking_for, type: Array
  field :active, type: String
  field :page_url, type: String
  field :pictures_page_url, type: String
  field :picture_urls, type: Array
  field :total_pictures, type: Integer
  field :total_followers, type: Integer
  field :total_friends, type: Integer
  field :latest_activity, type: Date
  belongs_to :city, optional: true
  belongs_to :state, optional: true
  validates :uid, :age, :gender, :username, :page_url, :pictures_page_url, presence: true
  validates_uniqueness_of :uid, :username
end

class DataError
  # A collection to store documents that failed inserting or updating. So the data can still be saved and investigated later.
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
end

class Session
  include Mongoid::Document
  include Mongoid::Timestamps
  field :runtime, type: Float # in seconds
  field :total_friends, type: Integer
  field :total_followers, type: Integer
  field :total_following, type: Integer
  field :pages_requested, type: Array
  field :pictures_liked, type: Array
  embedded_in :user
end

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :username, type: String
  field :members_liked, type: Array
  embeds_many :sessions
  validates_uniqueness_of :username
end

# user = User.where(username: 'zumbettella2').first
# user ? nil : user = User.create!(username: 'zumbettella2')
# puts user.sessions.create!(pages_requested: ['bliakhjsdcf2'], pictures_liked: ['poierjnmgpoeiwrj2'])

# member = Member.where(gender: 'M', age: 29).first
# member.sessions.create!(pages_requested:)
# member.set(sess)

# users = Member.where(gender: 'M', age: 29)
# puts users
# state = State.where(name: 'Washington').first
# puts state.cities.first.attributes
# city = City.where(name: 'Spokane').first
# puts city.state

# city = City.create!(name: 'Spokane',
#                     users_page_url: 'https://fakeurl.com',
#                     page_url: 'https://fakeurl.com',
#                     total_users: 43_000,
#                     pages_scraped: 1,
#                     scraped_all_pages: false,
#                     state: state,
#                     pages_to_scrape: 400)
# colorize(city.attributes, :green)

# state = State.create!(name: 'California',
#                       users_page_url: 'https://fakeurl.com',
#                       page_url: 'https://fakeurl.com',
#                       cities_page_url: 'https://fakeurl2.com',
#                       total_users: 43_000,
#                       total_cities: 400)
# colorize(state.attributes, :green)

# member = Member.create!(
#   uid: '102934',
#   age: 20,
#   gender: 'M',
#   username: 'SpokaneUser2',
#   orientation: 'Straight',
#   style: 'Exploring',
#   page_url: 'blah.com',
#   pictures_page_url: 'blank'
#   # city: city,
#   # state: city.state
# )
#
# puts member.attributes
# colorize(member.state.attributes, :blue)
# colorize(member.city.attributes, :blue)
