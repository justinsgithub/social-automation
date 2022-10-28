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
  field :site_id, type: String
  field :age, type: Integer
  field :gender, type: String
  field :username, type: String
  field :orientation, type: String
  field :style, type: String
  field :page_url, type: String
  field :pictures_page_url, type: String
  field :picture_urls, type: Array
  field :total_pictures, type: Integer
  field :total_followers, type: Integer
  field :total_friends, type: Integer
  field :last_activity, type: Date
  belongs_to :city
  belongs_to :state
  validates :site_id, :age, :gender, :username, :page_url, :pictures_page_url, presence: true
  validates_uniqueness_of :site_id, :username
end

class DataError
  # A collection to store documents that failed inserting or updating. So the data can still be saved and investigated later.
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
end

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

# user = User.create!(
#   site_id: '102934',
#   age: 20,
#   gender: 'M',
#   username: 'SpokaneUser2',
#   orientation: 'Straight',
#   style: 'Exploring',
#   page_url: 'blah.com',
#   pictures_page_url: 'blank',
#   city: city,
#   state: city.state
# )
#
# colorize(user.attributes, :green)
# colorize(user.state.attributes, :blue)
# colorize(user.city.attributes, :blue)
