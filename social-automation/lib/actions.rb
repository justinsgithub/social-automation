# frozen_string_literal: true

require 'selenium-webdriver'

require_relative './secrets'

require_relative './helpers'

require_relative './selectors'

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

  DRIVER.find_element(:xpath, S[:username_input]).send_keys USERNAME

  DRIVER.find_element(:xpath, S[:password_input]).send_keys PASSWORD

  DRIVER.find_element(:xpath, S[:login_button]).click

  sleep 3
end
