# frozen_string_literal: true

require 'mongo'

require_relative '../lib/colorize'

mongo_uri = ENV['SOCIAL_MONGO_URI']

unless mongo_uri
  puts colorize('MongoDB uri environment variable not found', :red)
  return
end

client = Mongo::Client.new(mongo_uri, database: 'unitedStates')

database_names = client.database_names

puts "\nLIST OF DATABASES:\n"

database_names.each { |db| puts colorize(db, :blue) }

us_db = client.database

us_states = us_db.collection_names

puts "\nLIST OF U.S. STATES:\n"

us_states.sort.each { |state| puts colorize(state, :blue) }
