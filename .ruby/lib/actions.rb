# frozen_string_literal: true

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

  return nil if (DRIVER.title.include? 'File Not Found') || (DRIVER.title.include? 'available')

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
  (colorize('LOGIN PAGE QUTTING', :red) && DRIVER.quit) if DRIVER.title == LOGIN_TITLE
  member.delete && return unless new_data

  puts "\nNEW DATA FOR MEMBER\n"
  colorize(new_data, :blue)
  member.update_attributes(new_data)
rescue Exception => e
  colorize(e, :red)
  (colorize("LOGIN PAGE QUTTING\n\n #{e}", :red) && DRIVER.quit) if DRIVER.title == LOGIN_TITLE
  exit if DRIVER.title == LOGIN_TITLE
end

def update_state_members(state = :Idaho, limit = 50)
  members = State.where(name: state).first.members.where(gender: 'M', active: nil).limit(limit)
  members.each do |member|
    sleep(15)
    puts "\nOLD DATA FOR MEMBER\n"
    colorize(member.attributes, :green)
    update_member(member)
  end
end

def track_update_session(user = init(USERNAME, PASSWORD))
  t1 = Time.now
  begin
    update_state_members # (state)
  rescue Exception => e
    colorize(e, :red)
    user.sessions.create!(pages_requested: PageObject.page_requests, runtime: Time.now - t1)
    return (colorize("LOGIN PAGE QUTTING\n\n #{e}", :red) && DRIVER.quit && exit) if DRIVER.title == LOGIN_TITLE
  end
  user.sessions.create!(pages_requested: PageObject.page_requests, runtime: Time.now - t1)
end

def like_pictures(gender = 'M', state = :Idaho)
  t1 = Time.now
  user = init(USERNAME, PASSWORD)
  fff = ProfilePage.new(user.page_url).fff
  pictures_liked = []
  members_liked = []
  members = Member.where(gender: gender, state: State.where(name: state).first).nin(_id: user.members_liked).limit(50)
  members.each do |member|
    pictures_page = PicturesPage.new(member.pictures_page_url)
    pic_urls = pictures_page.picture_urls
    pic_urls.length > 3 && pic_urls = pic_urls[0..2]
    pic_urls.each do |url|
      DRIVER.get(url)
      pictures_page.scroll_to_bottom
      pictures_page.like_picture
      pictures_liked.push(url)
      sleep 3
    end
    sleep 1
    members_liked.push(member._id)
  rescue Exception => e
    puts e
    next
  end
  user.add_to_set(members_liked: members_liked)
  user.sessions.create!(
    total_friends: fff[:friends],
    total_followers: fff[:followers],
    total_following: fff[:following],
    pages_requested: PageObject.page_requests,
    pictures_liked: pictures_liked,
    runtime: Time.now - t1
  )
end
