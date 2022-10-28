# frozen_string_literal: true

# this file is for functions to clean up mongodb databases and migrate them into 1 database
# v1 of the app was written when I had very little experience and was learning on my own
# the data for app has terrible organization and is using 4 different databases when it should just be using 1

require 'mongo'

require_relative './helpers'

require_relative './secrets'

require_relative 'models'

# CITIES_DB = Mongo::Client.new(MONGO_URI, database: 'CitiesData')
#
# US_USERS = Mongo::Client.new(MONGO_URI, database: 'UnitedStatesUsersData')
#
# ALL_USERS = Mongo::Client.new(MONGO_URI, database: 'users')

# def cities_pages_to_scrape(state_name)
#   colorize("GETTING USERS PAGE URL FOR ALL CITIES IN #{state_name} \n", :green)
#
#   city_links = US_DB[state_name].find({ name: state_name }).first[:cityLinks]
#
#   completed_city_links = US_DB[state_name].find({ name: state_name }).first[:completedCities]
#
#   colorize("SCRAPED #{completed_city_links.length} CITIES FOR USER DATA \n", :green)
#
#   # user_links = [f'{link}/{my_vars["users"]}' for link in city_links]
#
#   # USERS is a unique nickname that the website uses that I do not want visible to the public
#
#   puts "CITIES TO SCRAPE: \n"
#
#   city_links.map { |link| !completed_city_links.include?("#{link}/#{USERS}") ? "#{link}/#{USERS}" : nil }.compact
# end

def us_states_data
  db = Mongo::Client.new(MONGO_URI, database: 'unitedStates')

  db.database.collections.map do |collection|
    collection.find({ name: collection.name }).first
  end
end

def migrate_state(state_data)
  state = State.create(
    name: state_data[:name],
    page_url: state_data[:href],
    cities_page_url: state_data[:citiesLink],
    users_page_url: "#{state_data[:href]}/#{USERS}",
    total_users: state_data[:totalUsers],
    total_cities: state_data[:totalCities]
  )
  state.persisted? == true ? state : DataError.create!(state.attributes)
end

def migrate_states
  us_states_data.each { |state_data| migrate_state(state_data) }
end

def state_cities_data(state)
  Mongo::Client.new(MONGO_URI, database: 'CitiesData').database.collection(state).find
end

def migrate_city(city_data, city_state)
  city = City.create(name: city_data[:name],
                     page_url: city_data[:usersLink].gsub("/#{USERS}", ''),
                     users_page_url: city_data[:usersLink],
                     total_users: city_data[:totalUsers],
                     pages_to_scrape: city_data[:pagesToScrape],
                     pages_scraped: city_data[:pagesScraped],
                     scraped_all_pages: city_data[:completedScraping],
                     state: State.where(name: city_state).first)
  city.persisted? == true ? city : DataError.create!(city.attributes)
end

def migrate_state_cities(state)
  state_cities_data(state).each { |city_data| migrate_city(city_data, state) }
end

def migrate_all_cities
  State.all.map(&:name).each { |state_name| migrate_state_cities(state_name) }
end

# colorize(us_states_data, :blue)
# colorize(migrate_state(:Washington), :blue)
# colorize(migrate_states, :blue)
# colorize(state_cities_data(:Alabama), :blue)
# colorize(migrate_city(state_cities_data(:Alabama).first, :Alabama), :blue)
# colorize(migrate_state_cities(:Alabama), :green)
# migrate_all_cities
