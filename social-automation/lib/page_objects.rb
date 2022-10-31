# frozen_string_literal: true

require 'selenium-webdriver'

require_relative './secrets'

# require_relative './helpers'

require_relative './models'

require_relative './selectors'

options = Selenium::WebDriver::Chrome::Options.new

options.add_argument("user-data-dir=selenium/#{USERNAME}")

DRIVER = Selenium::WebDriver.for :chrome, options: options

DRIVER.manage.window.maximize

# a class for helper methods, error checking, and element selectors for each page
class PageObject
  attr_reader :url, :title

  def initialize(url)
    @url = url
    DRIVER.get(url)
    @title = DRIVER.title
  end

  def send_keys(find_by, selector, text)
    DRIVER.find_element(find_by, selector).send_keys text
  end

  def click(find_by, selector)
    DRIVER.execute_script('arguments[0].click()', DRIVER.find_element(find_by, selector))
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

# login_page = LoginPage.new("#{BASE_URL}/home")
# puts login_page.url
# puts login_page.title
# login_page.login(USERNAME, PASSWORD)

def init(username, password)
  login_page = LoginPage.new("#{BASE_URL}/home")
  login_page.login(username, password)
  user = User.where(username: username).first
  user ? nil : user = User.create!(username: username)
  user
  # puts user.sessions.create!(pages_requested: ['bliakhjsdcf2'], pictures_liked: ['poierjnmgpoeiwrj2'])
end

def like_pictures
  user = init(USERNAME, PASSWORD)
  pages_requested = []
  pictures_liked = []
  members_liked = []
  members = Member.where(gender: 'M', state: State.where(name: :Idaho).first).limit(200)
  members.each do |member|
    pictures_page = PicturesPage.new(member.pictures_page_url)
    pages_requested.push(member.pictures_page_url)
    pic_urls = pictures_page.picture_urls
    pic_urls.length > 3 && pic_urls = pic_urls[0..2]
    pic_urls.each do |url|
      DRIVER.get(url)
      pages_requested.push(url)
      pictures_page.scroll_to_bottom
      pictures_page.like_picture
      pictures_liked.push(url)
      sleep 1
    end
    members_liked.push(member._id)
  rescue Error => e
    puts e
    next
  end
  user.update_attributes!(members_liked: members_liked)
  user.sessions.create!(pages_requested: pages_requested, pictures_liked: pictures_liked)
end
