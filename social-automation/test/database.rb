# frozen_string_literal: true

require 'mongo'

require_relative '../lib/helpers'

MONGO_URI = ENV['SOCIAL_MONGO_URI']

unless MONGO_URI
  colorize('MongoDB uri environment variable not found', :red)
  return
end

def united_states_db
  client = Mongo::Client.new(MONGO_URI, database: 'unitedStates')

  database_names = client.database_names

  puts "\nLIST OF DATABASES:\n"

  database_names.each { |db| colorize(db, :blue) }

  us_db = client.database

  us_states = us_db.collection_names

  puts "\nLIST OF U.S. STATES:\n"

  us_states.sort.each { |state| colorize(state, :blue) }
end

def insert
  client = Mongo::Client.new(MONGO_URI, database: 'test')

  collection = client[:people]

  doc = {
    name: 'Steve',
    hobbies: ['hiking', 'tennis', 'fly fishing'],
    siblings: {
      brothers: 0,
      sisters: 1
    }
  }

  colorize(doc, :blue)

  result = collection.insert_one(doc)

  result.n # returns 1, because one document was inserted

  colorize(result, :blue)
end
