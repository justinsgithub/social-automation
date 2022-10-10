# frozen_string_literal: true

require 'selenium-webdriver'

require_relative '../secrets'

require_relative './helpers'

options = Selenium::WebDriver::Chrome::Options.new

options.add_argument('user-data-dir=selenium-user')

DRIVER = Selenium::WebDriver.for :chrome, options: options

def login
  DRIVER.manage.window.maximize

  DRIVER.get "#{BASE_URL}/home"

  sleep 3

  unless DRIVER.title == LOGIN_TITLE
    colorize('Already Logged In', :green)
    return
  end

  DRIVER.find_element(:id, 'remember_me').click

  DRIVER.find_element(:xpath, '/html/body/div[3]/div/div[3]/div/main/div/div[1]/form/div[1]/div[1]/div/div/input').send_keys USERNAME

  DRIVER.find_element(:xpath, '/html/body/div[3]/div/div[3]/div/main/div/div[1]/form/div[1]/div[2]/div/div/input').send_keys PASSWORD

  DRIVER.find_element(:xpath, '/html/body/div[3]/div/div[3]/div/main/div/div[1]/form/div[2]/button').click

  sleep 3
end

# def scrape_state_data
#   # already have this data in database, so just logging to console to ensure code is working properly in Ruby
#
#   DRIVER.get("#{BASE_URL}/p/united-states")
#
#   state_elements = DRIVER.find_elements(:xpath, '//*[@id="ptr-main-element"]//main/div[@class="mw8 nl2 nr2"]//a')
#
#   # state_names = state_elements.map { |element| element.text }
#   # below is a more concise way to pass a block to map
#   state_names = state_elements.map(&:text)
#
#   puts 'NAME OF EACH STATE:'
#   colorize(state_names, :blue)
#
#   puts 'URLS FOR EACH STATE PAGE:'
#   # state_hrefs = [ state_element.get_attribute("href") for state_element in state_elements ]
#   state_hrefs = state_elements.map { |element| element.attribute 'href' }
#   colorize(state_hrefs, :blue)
#
#   puts 'URLS FOR EACH STATE SHOWING WHICH CITIES ARE AVAILABLE WITHIN THAT STATE:'
#   # state_city_links = [ state_href + "/" + my_vars["within"] for state_href in state_hrefs ]
#   state_city_links = state_hrefs.map { |href| "#{href}/related" }
#   colorize(state_city_links, :blue)
#
#   puts 'DATA FOR EACH STATE:'
#   (0...state_elements.length).each do |x|
#     state = {}
#
#     sleep(1)
#
#     state[:name] = state_names[x]
#
#     state[:href] = state_hrefs[x]
#
#     state[:citiesLink] = state_city_links[x]
#
#     DRIVER.get(state[:href])
#
#     sleep(1)
#
#     num_users = DRIVER.find_element(:xpath, '//*[@id="ptr-main-element"]/header/div/nav/div/a[2]//span').text
#
#     num_cities = DRIVER.find_element(:xpath, '//*[@id="ptr-main-element"]/header/div/nav/div/a[5]//span').text
#
#     state[:totalUsers] = extract_number(num_users)
#
#     state[:totalCities] = extract_number(num_cities)
#
#     DRIVER.get(state[:citiesLink])
#
#     sleep(1)
#
#     DRIVER.execute_script('window.scrollTo(0, document.body.scrollHeight);')
#
#     sleep(1)
#
#     colorize(state, :blue)
#   end
# end
