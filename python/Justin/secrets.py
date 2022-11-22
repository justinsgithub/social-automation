username = "lovedaddyj"
password = "Hockey1343!"
datadir = "user-data-dir=selenium"

userUrl = "kinksterUrl"
pa = "?page="

canada_url = "https://fetlife.com/p/canada"
base_url = "https://fetlife.com"
sign_in = base_url + "/users/sign_in"
profile_url = base_url + "/users/"
us_places = "https://fetlife.com/p/united-states"
users_link = "/kinksters"
canada_locations_selector = '//div[@class="mw8 nl2 nr2"]//a'
number_of_users_span_selector = '//span[@class="dib ph1 ml2-ns ml1 f7 fw4 br1 text bg-gray-500 theme-gray-950"]'




username_in = "/html/body/div[3]/div/div[3]/div/main/div/div[1]/form/div[1]/div[1]/div/div/input"
password_in = "/html/body/div[3]/div/div[3]/div/main/div/div[1]/form/div[1]/div[2]/div/div/input"
login_button = "/html/body/div[3]/div/div[3]/div/main/div/div[1]/form/div[2]/button"
user_name_selector = "//a[@class='link f5 fw7 secondary mr1']"
user_details_selector = "//div[@id='main-content']//main//div[@style='max-height: 60px;']//span[@class='f6 fw7 gray-300']"
view_pictures_selector = "//main//div//a[@class='link gray hover-gray-300 dot-separated'][1]"
picture_link_selector = "//a[@class='aspect-ratio--1x1 relative db bg-animate no-underline overflow-hidden br1 tap-highlight-transparent bg-gray-900 hover-bg-gray-950']"


follow_button_selector = '//button[@name="button"][@data-color="secondary"]'
# follow_button_selector = '//button[@name="button"][1]'
following_button_selector = '//button[@name="button"][@data-color="lined"]'
# following_button_selector = '//button[@name="button"][2]'
like_button_selector = '//a[@title="Love"][text()="Love"]'
#like_button_selector = '//a[text()="Love"]'
#like_button_selector = '//a[contains(text(), "Love")]'
comment_input_selector = "//div[@id='new_comment']//form/div/div/textarea"
comment_button_selector = "//div[@id='new_comment']//form/div/div/textarea//button[1]"