# frozen_string_literal: true

# constants for driver.find_element(s) selectors because some of the strings are so long

S = {
  state_elements: '//*[@id="ptr-main-element"]//main/div[@class="mw8 nl2 nr2"]//a',
  num_users: '//*[@id="ptr-main-element"]/header/div/nav/div/a[2]//span',
  num_cities: '//*[@id="ptr-main-element"]/header/div/nav/div/a[5]//span',
  city_elements: '//*[@id="ptr-main-element"]//main//div[@class="mw8 nl2 nr2"]//a',
  number_of_users_text: '//*[@id="ptr-main-element"]/header/div/nav/div/a[2]//span',
  city_name: '//h1[@class="mv0 f4 f25-ns fw7 lh-copy tl secondary breakword"]',
  username_input: '/html/body/div[3]/div/div[3]/div/main/div/div[1]/form/div[1]/div[1]/div/div/input',
  password_input: '/html/body/div[3]/div/div[3]/div/main/div/div[1]/form/div[1]/div[2]/div/div/input',
  login_button: '/html/body/div[3]/div/div[3]/div/main/div/div[1]/form/div[2]/button',
  user_details_elements: "//div[@id='main-content']//main//div[@style='max-height: 60px;']//span[@class='f6 fw7 gray-300']",
  view_picture_elements: "//main//div//a[@class='link gray hover-gray-300 dot-separated'][1]",
  username_elements: "//a[@class='link f5 fw7 secondary mr1']",
  picture_url: "//a[@class='aspect-ratio--1x1 relative db bg-animate no-underline overflow-hidden br1 tap-highlight-transparent bg-gray-900 hover-bg-gray-950']",
  last_post: '//*[@id="ptr-main-element"]//div/main//a/time',
}.freeze
