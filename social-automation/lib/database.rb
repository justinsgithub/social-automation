# frozen_string_literal: true

require 'mongo'

require_relative './helpers'

require_relative '../secrets'

US_DB = Mongo::Client.new(MONGO_URI, database: 'unitedStates')

CITIES_DB = Mongo::Client.new(MONGO_URI, database: 'CitiesData')

US_USERS = Mongo::Client.new(MONGO_URI, database: 'UnitedStatesUsersData')

ALL_USERS = Mongo::Client.new(MONGO_URI, database: 'users')

def cities_pages_to_scrape(state_name)
  colorize("GETTING USERS PAGE URL FOR ALL CITIES IN #{state_name} \n", :green)

  city_links = US_DB[state_name].find({ name: state_name }).first[:cityLinks]

  completed_city_links = US_DB[state_name].find({ name: state_name }).first[:completedCities]

  colorize("SCRAPED #{completed_city_links.length} CITIES FOR USER DATA \n", :green)

  # user_links = [f'{link}/{my_vars["users"]}' for link in city_links]

  # USERS is a unique nickname website uses that I do not want visible to the public

  puts "CITIES TO SCRAPE: \n"

  city_links.map { |link| !completed_city_links.include?("#{link}/#{USERS}") ? "#{link}/#{USERS}" : nil }.compact
end
