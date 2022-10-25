# frozen_string_literal: true

require_relative './secrets'

require_relative './helpers'

require_relative './actions'

require_relative './database'

require_relative './selectors'

def scrape_state_data
  # already have this data in database, so just logging to console to ensure code is working properly in Ruby

  DRIVER.get("#{BASE_URL}/p/united-states")

  state_elements = DRIVER.find_elements(:xpath, S[:state_elements])

  # state_names = state_elements.map { |element| element.text }
  # below is a more concise way to pass a block to map
  state_names = state_elements.map(&:text)

  puts 'NAME OF EACH STATE:'
  colorize(state_names, :blue)

  puts 'URLS FOR EACH STATE PAGE:'
  # state_hrefs = [ state_element.get_attribute("href") for state_element in state_elements ]
  state_hrefs = state_elements.map { |element| element.attribute 'href' }
  colorize(state_hrefs, :blue)

  puts 'URLS FOR EACH STATE SHOWING WHICH CITIES ARE AVAILABLE WITHIN THAT STATE:'
  # state_city_links = [ state_href + "/" + my_vars["within"] for state_href in state_hrefs ]
  state_city_links = state_hrefs.map { |href| "#{href}/related" }
  colorize(state_city_links, :blue)

  puts 'DATA FOR EACH STATE:'
  (0...state_elements.length).each do |x|
    state = {}

    sleep(1)

    state[:name] = state_names[x]

    state[:href] = state_hrefs[x]

    state[:citiesLink] = state_city_links[x]

    DRIVER.get(state[:href])

    sleep(1)

    num_users = DRIVER.find_element(:xpath, S[:num_users]).text

    num_cities = DRIVER.find_element(:xpath, S[:num_cities]).text

    state[:totalUsers] = extract_number(num_users)

    state[:totalCities] = extract_number(num_cities)

    DRIVER.get(state[:citiesLink])

    sleep(1)

    DRIVER.execute_script('window.scrollTo(0, document.body.scrollHeight);')

    sleep(1)

    city_elements = DRIVER.find_elements(:xpath, S[:city_elements])

    city_names = city_elements.map(&:text)

    city_links = city_elements.map { |element| element.attribute 'href' }

    state[:cityLinks] = city_links

    state[:cityNames] = city_names

    state[:completedCities] = []

    state[:scrapedAllCities] = false

    # result = united_states_db[state[:name]].insert_one(state)

    colorize(state, :blue)
  end
end

def scrape_city_data(state_name)
  # [CITY_DATA_TEST_URL].each do |url|
  cities_pages_to_scrape(state_name).each do |url|
    DRIVER.get(url)

    sleep(1)

    city = {}

    number_of_users_text = DRIVER.find_element(:xpath, S[:number_of_users_text]).text

    number_of_users = extract_number(number_of_users_text)

    city_name = DRIVER.find_element(:xpath, S[:city_name]).text

    # 450 is the max number of users pages site will let you look at. 20 is number of users displayed per page
    pages_to_scrape = (number_of_users / 20) > 450 ? 450 : (number_of_users / 20)

    colorize("#{pages_to_scrape} PAGES TO SCRAPE", :green)

    city[:name] = city_name

    city[:totalUsers] = number_of_users

    city[:pagesToScrape] = pages_to_scrape

    city[:pagesScraped] = 1

    city[:usersLink] = url

    city[:completedScraping] = false

    # state_collection = city_data_db[state_name]

    colorize(city, :blue)

    # result1 = state_collection.insert_one(city)

    # print( f('finished inserting {city}, into {state_name} result = {result1}'))

    # result2 = united_states_db[state_name].update_one( { "name": state_name }, { "$addToSet": { "completedCities": url } })

    # print( f('added {city_name} to scraped cities for {state_name}, result = {result2}'))
  end
end

def scrape_users_page(state_name, city_name)
  user_details_elements = DRIVER.find_elements(:xpath, S[:user_details_elements])

  view_picture_elements = DRIVER.find_elements(:xpath, S[:view_picture_elements])

  username_elements = DRIVER.find_elements(:xpath, S[:username_elements])

  user_details_text = user_details_elements.map(&:text)

  view_pictures_text = view_picture_elements.map(&:text)

  user_profile_links = username_elements.map { |element| element.attribute 'href' }

  user_picture_links = user_profile_links.map { |link| "#{link}/pictures" }

  usernames = username_elements.map(&:text)

  user_ids = user_profile_links.map { |link| extract_number(link).to_s }

  user_ages = user_details_text.map { |text| extract_number(text) }

  user_genders = user_details_text.map { |text| get_gender(text) }

  user_styles = user_details_text.map { |text| text.split(' ')[-1] }

  user_num_pics = view_pictures_text.map { |text| extract_number(text) }

  (0...user_num_pics.length).each do |x|
    user = {}
    user[:site_id] = user_ids[x]
    user[:profileLink] = user_profile_links[x]
    user[:pictureLink] = user_picture_links[x]
    user[:userName] = usernames[x]
    user[:age] = user_ages[x]
    user[:gender] = user_genders[x]
    user[:style] = user_styles[x]
    user[:numberOfPics] = user_num_pics[x]
    user[:jFollows] = false
    user[:lFollows] = false
    user[:xFollows] = false
    user[:followsMe] = false
    user[:iLikedPictures] = false
    user[:jLikedPictures] = false
    user[:lLikedPictures] = false
    user[:xLikedPictures] = false
    user[:city] = city_name
    user[:state] = state_name
    user[:active] = true
    user[:fatalErr] = false
    colorize(user, :blue)
    # result = US_USERS[city_name].insert_one(user)
    # colorize(result, :green)
  end
end

def scrape_city_users(state_name)
  cities_to_scrape = CITIES_DB[state_name].find({ completedScraping: false })

  cities_to_scrape.each do |city|
    colorize(city, :blue)

    start_page = city[:scrapedPages] + 1

    end_page = city[:pagesToScrape]

    if start_page >= end_page

      result = CITIES_DB[state_name].update_one({ "_id": city[:_id] }, { completedScraping: true })

      next
    end

    # this range might need to be inclusive for end_page, check later
    (start_page...end_page).each do |x|
      page_to_get = "#{city[:usersLink]}?page=#{x}"

      DRIVER.get(page_to_get)

      sleep(1)

      scrape_users_page(state_name, city[:name])

      # US_DB[state_name].update_one({ name: city[:name] }, { "$inc": { scrapedPages: 1 } })
    end
  end
end

def scrape_all_states_cities
  states = US_DB.database.collection_names

  states.each { |state| scrape_city_data(state) }
end

login
# scrape_state_data # PASSING
# scrape_city_data(:Washington) # PASSING
# scrape_city_users(:Washington) # PASSING
# scrape_all_states_cities

DRIVER.quit
