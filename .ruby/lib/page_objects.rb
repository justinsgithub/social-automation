# frozen_string_literal: true

import 'selenium-webdriver'

require_relative './secrets'

require_relative './selectors'

options = Selenium::WebDriver::Chrome::Options.new

options.add_argument("user-data-dir=selenium/#{USERNAME}")

DRIVER = Selenium::WebDriver.for :chrome, options: options

DRIVER.manage.window.maximize

# a class for helper methods, error checking, and element selectors for each page
class PageObject
  attr_reader :url, :title

  @@page_requests = []

  def initialize(url)
    @url = url
    DRIVER.get(url)
    @@page_requests.push(url)
    sleep(0.5)
    @title = DRIVER.title
  end

  def self.page_requests
    @@page_requests
  end

  def send_keys(find_by, selector, text)
    DRIVER.find_element(find_by, selector).send_keys text
  end

  def click(find_by, selector)
    DRIVER.execute_script('arguments[0].click()', DRIVER.find_element(find_by, selector))
  end

  def texts(find_by, selector)
    texts = []
    e = DRIVER.find_elements(find_by, selector)
    !e.empty? && texts = e.map(&:text)
    texts
  end

  def text(find_by, selector)
    text = 'not found'
    e = DRIVER.find_elements(find_by, selector)
    !e.empty? && text = e.first.text
    text
  end

  def hrefs(find_by, selector)
    DRIVER.find_elements(find_by, selector).map { |element| element.attribute 'href' }
  end

  def scroll_to_bottom
    DRIVER.execute_script('window.scrollTo(0, document.body.scrollHeight);')
  end

  def click_likes
    DRIVER.find_elements(:link_text, 'Love').each do |button|
      DRIVER.execute_script('arguments[0].click()', button)
      sleep(0.2)
    end
  end
end

# login page first tries to access home page url and if its redirected to login page then logs in
class LoginPage < PageObject
  def login(username, password)
    @title != LOGIN_TITLE && return
    sleep 2

    send_keys(:xpath, S[:username_input], username)

    send_keys(:xpath, S[:password_input], password)

    click(:id, 'remember_me')

    click(:xpath, S[:login_button])
    sleep 3
  end
end

# page that shows thumbnails for all of a users pictures
class PicturesPage < PageObject
  def picture_urls
    hrefs(:xpath, S[:picture_url])
  end

  def like_picture
    scroll_to_bottom
    click(:link_text, 'Love')
  end
end

# user / member profile page
class ProfilePage < PageObject
  def username
    text(:xpath, '//*[@id="ptr-main-element"]/div[2]/div/header[1]/div/div[1]/main/div/div[1]/div[2]/h1/span[1]')
  end

  def age_gender_style
    text(:xpath, '//span[@class="fw7 gray-200 f4-l f16 dib us-none"]')
  end

  def age
    age_gender_style.strip.gsub(/\D/, '').to_i
  end

  def gender
    age_gender_style.split(' ')[0].split(' ')[0].gsub(/\d/, '')
  end

  def style
    age_gender_style.split(' ')[-1]
  end

  def city
    city = text(:xpath, '//*[@id="ptr-main-element"]/div[2]/div/header[1]/div/div[1]/main/div/div[1]/div[2]/p/span[1]/a')
    city == 'not found' && city = 'Antartica'
    city
  end

  def extra_categories
    texts(:xpath, '//div[@class="flex-none w140-ns gray-400 f5"]')
  end

  def orientation
    orientation = 'Not Applicable'
    (extra_categories.include? 'Orientation') && orientation = text(:xpath, '//span[@class="bb bt-0 br-0 bl-0 b-gray-400 b-dotted mr1"]')
    orientation
  end

  def fff
    sleep 1
    scroll_to_bottom
    sleep 1
    arr = texts(:xpath, '//a[@class="link gray-400 hover-gray-300"]')
    puts(arr)
    {
      friends: safe_extract_number(arr.select { |t| t.include? 'Friends' }.first) || 0,
      followers: safe_extract_number(arr.select { |t| t.include? 'Followers' }.first) || 0,
      following: safe_extract_number(arr.select { |t| t.include? 'Following' }.first) || 0
    }
  end

  def active
    active = 'Not Applicable'
    (extra_categories.include? 'Active') && active = text(:xpath, '//div[contains(text(), "Active")]/following-sibling::div[1]')
    active
  end

  def looking_for
    looking_for = []
    (extra_categories.include? 'Looking for') && looking_for = texts(:xpath, '//div[@class="flex-auto mv0 gray-150 flex-auto"]/div')
    looking_for
  end

  def number_of_pictures
    num_pics = 0
    text = text(:xpath, '//a[@title="View all pictures"]')
    text != 'not found' && num_pics = text(:xpath, '//a[@title="View all pictures"]/following-sibling::span[1]').strip.gsub(/\D/, '').to_i
    num_pics
  end

  def latest_activity
    sleep(0.5)
    scroll_to_bottom
    sleep(0.5)
    e = DRIVER.find_elements(:xpath, '//span[@class="f6 gray-500 nowrap"]/span[2]/time') # .attribute 'datetime'
    e.empty? ? nil : e.first.attribute('datetime')
  end
end

# 3.times { ProfilePage.new('https://google.com') }
#
# puts PageObject.page_requests

# login_page = LoginPage.new("#{BASE_URL}/home")
# puts login_page.url
# puts login_page.title
# login_page.login(USERNAME, PASSWORD)
