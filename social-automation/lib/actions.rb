# frozen_string_literal: true

require 'benchmark'

require_relative 'models'

require_relative 'page_objects'

require_relative 'helpers'

def init(username, password)
  login_page = LoginPage.new("#{BASE_URL}/home")
  login_page.login(username, password)
  user = User.where(username: username).first
  user ? nil : user = User.create!(username: username)
  user
  # puts user.sessions.create!(pages_requested: ['bliakhjsdcf2'], pictures_liked: ['poierjnmgpoeiwrj2'])
end

def member_profile_data(profile_url)
  page = ProfilePage.new(profile_url)

  return nil if DRIVER.title.include? 'File Not Found'

  profile_data = { age: page.age, gender: page.gender, style: page.style, orientation: page.orientation, active: page.active,
                   total_pictures: page.number_of_pictures }

  city = City.where(name: page.city).first

  city && profile_data[:city] = city

  !page.looking_for.empty? && profile_data[:looking_for] = page.looking_for

  page.latest_activity && profile_data[:latest_activity] = page.latest_activity

  profile_data
end

def update_member(member)
  new_data = member_profile_data(member.page_url)
  DRIVER.quit if DRIVER.title == LOGIN_TITLE
  (colorize('LOGIN PAGE QUTTING', :red) && DRIVER.quit) if DRIVER.title == LOGIN_TITLE
  member.destroy && return unless new_data

  puts "\nNEW DATA FOR MEMBER\n"
  colorize(new_data, :blue)
  member.update_attributes!(new_data)
end

def update_state_members(state, limit = 50)
  members = State.where(name: state).first.members.where(gender: 'M', active: nil).limit(limit)
  pages_requested = []
  members.each do |member|
    sleep(5)
    puts "\nOLD DATA FOR MEMBER\n"
    colorize(member.attributes, :green)
    update_member(member)
    pages_requested.push(member.page_url)
  rescue Exception => e
    colorize(e, :red)
    (colorize('LOGIN PAGE QUTTING', :red) && DRIVER.quit) if DRIVER.title == LOGIN_TITLE
    next
  end
  pages_requested
end

def track_update_session(user, state)
  pages_requested = []
  runtime = 0
  # user = init(USERNAME, PASSWORD)
  begin
    runtime = Benchmark.realtime { pages_requested = update_state_members(state) }
  rescue Exception => e
    colorize(e, :red)
    user.sessions.create!(pages_requested: pages_requested, runtime: runtime)
    (colorize('LOGIN PAGE QUTTING', :red) && DRIVER.quit) if DRIVER.title == LOGIN_TITLE
    exit if DRIVER.title == LOGIN_TITLE
    return
  end
  user.sessions.create!(pages_requested: pages_requested, runtime: runtime)
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
  rescue Exception => e
    puts e
    next
  end
  user.update_attributes!(members_liked: members_liked)
  user.sessions.create!(pages_requested: pages_requested, pictures_liked: pictures_liked)
end
