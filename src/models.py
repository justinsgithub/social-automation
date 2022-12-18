# frozen_string_literal: true

from datetime import datetime
# from typing import Any, Dict, TypeVar
# from pymongo import MongoClient
import re
from random import randint
from time import sleep
import undetected_chromedriver as uc
from rich import print
from selenium.webdriver import Chrome
from selenium.webdriver.common.by import By
import my_secrets
import my_selectors

S = my_selectors.S

# DRIVER = uc.Chrome(user_data_dir="selenium/REPLACE")
# DRIVER = webdriver.Chrome()

# ali = TypeVar('ali')

# DRIVER: Chrome = uc.Chrome(user_data_dir=f'selenium/{my_secrets.USERNAME}')
DRIVER = uc.Chrome(user_data_dir=f'selenium/{my_secrets.USERNAME}')

# CLIENT: MongoClient[Dict[str, Any]] = MongoClient(my_secrets.MONGO_URI)
# DB = CLIENT['ali']

DRIVER.maximize_window()

# a class for helper methods, error checking, and element selectors for each page
class PageObject():
    page_requests: list[str] = []

    def __init__(self, url: str) -> None:
        PageObject.page_requests.append(url)
        self.url = url
        DRIVER.get(url)
        sleep(randint(1, 2))
        self.title = DRIVER.title
        sleep(randint(1, 2))

    def send_keys(_self, find_by: str, selector: str, text: str):
        DRIVER.find_element(find_by, selector).send_keys(text)

    def click(_self, find_by: str, selector: str):
        DRIVER.execute_script('arguments[0].click()', DRIVER.find_element(find_by, selector))

    def texts(_self, find_by: str, selector: str):
        texts = []
        els = DRIVER.find_elements(find_by, selector)
        if len(els) > 0: 
            texts = [el.text.strip() for el in els]
        return texts

    def text(_self, find_by: str, selector: str) -> str:
        text = ''
        els = DRIVER.find_elements(find_by, selector)
        if len(els) > 0:
            text = els[0].text
        return text

    def hrefs(_self, find_by: str, selector: str) -> list[str]:
        els = DRIVER.find_elements(find_by, selector)
        return [el.get_attribute('href') for el in els]

    def scroll_to_bottom(_self):
        DRIVER.execute_script('window.scrollTo(0, document.body.scrollHeight);')

    def click_likes(_self):
        for el in DRIVER.find_elements(By.LINK_TEXT, 'Love'):
            DRIVER.execute_script('arguments[0].click()', el)
            sleep(0.2)

# login page first tries to access home page url and if its redirected to login page then logs in
class LoginPage(PageObject):
    def login(self, username: str, password: str):
        print('TITLE', self.title)
        if self.title == my_secrets.LOGIN_TITLE:

            sleep(2)

            self.send_keys(By.XPATH, S['username_input'], username)

            self.send_keys(By.XPATH, S['password_input'], password)

            self.click(By.ID, 'remember_me')

            self.click(By.XPATH, S['login_button'])

            sleep(3)
        else: 
            print('ALREADY LOGGED IN')
#
# # user / member profile page
class ProfilePage(PageObject):

    def __init__(self, url: str) -> None:
        super().__init__(url)
        if 'File Not Found' in self.title:
            return
        if "isn't available" in self.title:
            return
        self.username: str = self._username()
        self.age_gender_style = self._age_gender_style()
        self.age = self._age()
        self.role = self._role()
        self.gender = self._gender()
        self.location = self._location()
        self.extra_categories = self._extra_categories()
        self.orientation = self._orientation()
        self.friends_followers_following = self._friends_followers_following()
        self.friend_count = self._friend_count()
        self.follower_count = self._follower_count()
        self.following_count = self._following_count()
        self.active = self._active()
        self.looking_for = self._looking_for()
        self.roles = self._roles()
        self.relationships = self._relationships()
        self.ds_relationships = self._ds_relationships()
        self.picture_count = self._picture_count()
        self.last_activity = self._last_activity()

    def _username(self) -> str:
        return self.text(By.XPATH, '//*[@id="ptr-main-element"]/div[2]/div/header[1]/div/div[1]/main/div/div[1]/div[2]/h1/span[1]')

    def _age_gender_style(self) -> str:
        return self.text(By.XPATH, '//span[@class="fw7 gray-200 f4-l f16 dib us-none"]').strip()

    def _age(self) -> int:
        return int(re.sub(r"\D", "", self.age_gender_style))

    def _gender(self) -> str:
        gender = re.sub(r"\d", "", self.age_gender_style.split(' ')[0]) 
        if not (gender):
            gender = 'Not Specified'
        return gender

    def _role(self) -> str:
        role = 'Not Specified'
        data_array = self.age_gender_style.split(' ')
        if (len(data_array) > 1):
            role = data_array[-1]
        return role

    def _location(self) -> str:
        return ','.join(self.texts(By.XPATH, '//*[@id="ptr-main-element"]/div[2]/div/header[1]/div/div[1]/main/div/div[1]/div[2]/p//span//a'))

    def _extra_categories(self) -> list[str]:
        return self.texts(By.XPATH, '//div[@class="flex-none w140-ns gray-400 f5"]')

    def _orientation(self) -> str:
        orientation = 'Not Specified'
        if ('Orientation' in self.extra_categories):
            orientation = self.text(By.XPATH, '//span[@class="bb bt-0 br-0 bl-0 b-gray-400 b-dotted mr1"]')
        return orientation

    def _friends_followers_following(self):
        sleep(1)
        self.scroll_to_bottom()
        sleep(1)
        return self.texts(By.XPATH, '//a[@class="link gray-400 hover-gray-300"]')

    def _f_count(self, category: str) -> int:
        count = 0
        is_category = [word for word in self.friends_followers_following if category in word]
        if (len(is_category) > 0):
            numstr = re.sub(r"\D", "", is_category[0])
            count = int(numstr)
        return count

    def _friend_count(self) -> int:
        return self._f_count('Friends')

    def _follower_count(self) -> int:
        return self._f_count('Followers')
    
    def _following_count(self) -> int:
        return self._f_count('Following')

    def _active(self) -> str:
        active = 'Not Specified'
        if ('Active' in self.extra_categories):
            active = self.text(By.XPATH, '//div[contains(text(), "Active")]/following-sibling::div[1]')
        return active

    def _looking_for(self) -> list[str]:
        looking_for = []
        if ('Looking for' in self.extra_categories):
            xpath = '//*[@id="ptr-main-element"]/div[2]/div/header[1]/div/div[1]/main//div[contains(text(), "Looking for")]/following-sibling::div[1]/div'
            looking_for = self.texts(By.XPATH, xpath)
        return looking_for

    def _roles(self) -> list[str]:
        roles = []
        if ('Roles' in self.extra_categories):
            xpath = '//*[@id="ptr-main-element"]/div[2]/div/header[1]/div/div[1]/main//div[contains(text(), "Roles")]/following-sibling::div[1]/span'
            roles = self.texts(By.XPATH, xpath)
        return roles

    def _relationships(self) -> list[str]:
        relationships = []
        if ('Relationships' in self.extra_categories):
            xpath = '//*[@id="ptr-main-element"]/div[2]/div/header[1]/div/div[1]/main//div[text()="Relationships"]/following-sibling::div[1]/div'
            relationships = self.texts(By.XPATH, xpath)
        return relationships

    def _ds_relationships(self) -> list[str]:
        ds_relationships = []
        if ('D/s Relationships' in self.extra_categories):
            xpath = '//*[@id="ptr-main-element"]/div[2]/div/header[1]/div/div[1]/main//div[contains(text(), "D/s Relationships")]/following-sibling::div[1]/div'
            ds_relationships = self.texts(By.XPATH, xpath)
        return ds_relationships

    def _picture_count(self) -> int:
        pic_count = 0
        text = self.text(By.XPATH, '//a[@title="View all pictures"]')
        if(text):
            numstr = self.text(By.XPATH, '//a[@title="View all pictures"]/following-sibling::span[1]')
            if (numstr):
                pic_count = int(re.sub(r"\D", '', numstr))
        return pic_count

    def _video_count(self) -> int:
        return 0

    def _writing_count(self) -> int:
        return 0

    def _last_activity(self) -> datetime:
        # self.scroll_to_bottom()
        last_activity = '1997-11-16T04:20:52Z'
        els = DRIVER.find_elements(By.XPATH, '//span[@class="f6 gray-500 nowrap"]/span[2]/time')
        if (len(els) > 0):
            last_activity = els[0].get_attribute('datetime')
        return datetime.strptime(last_activity, '%Y-%m-%dT%H:%M:%S%z')

    def _into(_self):
        return

    def _curious_about(_self):
        return

    def _limits(_self):
        return

# class Member:
#     page_url: str
#
#     def __init__(self) -> None:
#         self.collection = DB['members']
#         self.page_url = 'blah'
#
#     def all(self):
#         return list(self.collection.find({}, limit=100))
#
# member = Member()
# print(member.page_url)
# print(member.collection)
# print(member.all())
#

LoginPage(f'{my_secrets.base_url}/home').login(my_secrets.USERNAME, my_secrets.PASSWORD)
#
# for url in my_secrets.TEST_PAGES:
#     member_page = ProfilePage(url)
#     print(member_page.__dict__)
    # print(member_page.username)
    # print(member_page.picture_count)
    # print(member_page.last_activity)
    # print(member_page.roles)
    # print(member_page.relationships)
    # print(member_page.ds_relationships)
    # print(member_page.looking_for)
    # print(member_page.active)
    # print(member_page.orientation)
    # print(member_page.friends_followers_following)
    # print(member_page.friend_count)
    # print(member_page.follower_count)
    # print(member_page.following_count)
    # print(member_page.role)
    # print(member_page.location)
    # print(member_page.extra_categories)
    # print(member_page.age_gender_style)
    # print(member_page.age)
    # print(member_page.gender)
    # print(PageObject.page_requests)




# page that shows thumbnails for all of a users pictures
# class PicturesPage < PageObject
#   def picture_urls
#     hrefs(:xpath, S[:picture_url])
#   end
#
#   def like_picture
#     scroll_to_bottom
#     click(:link_text, 'Love')
#   end
# end
# # 3.times { ProfilePage.new('https://google.com') }
# #
# # puts PageObject.page_requests
#
# # login_page = LoginPage.new("#{BASE_URL}/home")
# # puts login_page.url
# # puts login_page.title
# # login_page.login(USERNAME, PASSWORD)
