# frozen_string_literal: true

# this file is for functions to clean up mongodb databases and migrate them into 1 database
# v1 of the app was written when I had very little experience and was learning on my own
# the data for app has terrible organization and is using 4 different databases when it should just be using 1

require 'mongo'

require_relative './helpers'

require_relative './secrets'

require_relative 'models'

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

def state_members(state)
  Mongo::Client.new(MONGO_URI, database: 'users').database.collection(state).find
end

def migrate_member(member_data)
  member = Member.create(uid: member_data[:site_id],
                         age: member_data[:age],
                         gender: member_data[:gender],
                         username: member_data[:userName],
                         style: member_data[:style],
                         page_url: member_data[:profileLink],
                         pictures_page_url: member_data[:pictureLink],
                         state: State.where(name: member_data[:state]).first)
  member.persisted? == true ? member : DataError.create!(member.attributes)
end

def migrate_state_members(state)
  state_members(state).each { |member| puts migrate_member(member) }
end

def migrate_all_state_members
  Mongo::Client.new(MONGO_URI, database: 'users').database.collection_names.each { |state_name| puts migrate_state_members(state_name) }
end

# migrate_all_state_members
# colorize(migrate_member(state_members(:Colorado).first), :green)
# colorize(state_members(:Colorado), :green)
# colorize(us_states_data, :blue)
# colorize(migrate_state(:Washington), :blue)
# colorize(migrate_states, :blue)
# colorize(state_cities_data(:Alabama), :blue)
# colorize(migrate_city(state_cities_data(:Alabama).first, :Alabama), :blue)
# colorize(migrate_state_cities(:Alabama), :green)
# migrate_all_cities
