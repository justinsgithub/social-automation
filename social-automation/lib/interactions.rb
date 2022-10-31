# frozen_string_literal: true

require_relative './actions'

require_relative './models'

require_relative './helpers'

require_relative './secrets'

require_relative './selectors'

def picture_urls(user)
  DRIVER.get(user[:pictures_page_url])

  sleep(1)

  unless DRIVER.title != LOGIN_TITLE
    DRIVER.quit
    exit
  end

  urls = DRIVER.find_elements(:xpath, S[:picture_url]).map { |element| element.attribute 'href' }

  urls.length > 3 ? urls[0..2] : urls
end

def click_likes
  DRIVER.find_elements(:link_text, 'Love').each do |button|
    DRIVER.execute_script('arguments[0].click()', button)
    sleep(0.2)
  end
end

def give_likes(url)
  DRIVER.get(url)

  sleep(1)

  DRIVER.execute_script('window.scrollTo(0, document.body.scrollHeight);') # scroll to bottom

  sleep(1)

  click_likes
end

def like_pictures(state, username)
  colorize('liking users pictures', :green)

  count = 0

  members = Members.where(gender: 'M', state: State.where(name: state).first)

  user = User.new(name: username).upsert


  # users = ALL_USERS[state].find({ "xLikedPictures": false, "active": true, "fatalErr": false })

  members.each do |member|
    unless count < 100

      colorize('liked 100 users, quitting now', :red)

      DRIVER.quit

      exit
    end

    count += 1

    # next unless %w[M F].include? user[:gender]

    # colorize("#{member[:userName]} #{member[:age]} #{member[:gender]} #{member[:state]}", :green)

    urls = picture_urls(member)

    if urls.empty?

      colorize('NO PICTURES OR COULD NOT FIND PAGE', :red)

      ALL_USERS[state].update_one({ userName: user[:userName] }, "$set": { "fatalErr": true })

    else

      DRIVER.get(urls[0])

      last_post = DRIVER.find_element(:xpath, S[:last_post]).text

      year = last_post.gsub("\D", ' ').split(' ')[-1].to_i

      colorize("last post was #{last_post}, year = #{year}", :blue)

      if year < 40

        urls.each do |url|
          give_likes(url)
        end

      else
        DRIVER.execute_script('window.scrollTo(0, document.body.scrollHeight);') # scroll to bottom

        sleep(1)

        click_likes

        # ALL_USERS[state].update_one({ userName: user[:userName] }, "$set": { "active": false })
      end
      # ALL_USERS[state].update_one({ userName: user[:userName] }, "$set": { "xLikedPictures": true, "lastPicturePost": last_post })
    end
  end
end

login
like_pictures(:Washington)
