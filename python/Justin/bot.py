import re
from time import sleep

from selenium import webdriver
from selenium.common import exceptions
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from constants import my_vars, my_selectors, base_url
from db import update_data
import helpers

chrome_opts = Options()
chrome_opts.add_argument("user-data-dir=selenium")
driver = webdriver.Chrome(options=chrome_opts)


def login():
    username_in = my_selectors["username_in"]
    password_in = my_selectors["password_in"]
    login_button = my_selectors["login_button"]
    username = my_vars["username"]
    password = my_vars["password"]
    driver.maximize_window()
    driver.get(my_vars["home_page"])
    sleep(5)
    try:
        username_input = driver.find_element(By.XPATH, username_in)
        password_input = driver.find_element(By.XPATH, password_in)
        log_button = driver.find_element(By.XPATH, login_button)
        username_input.send_keys(username)
        password_input.send_keys(password)
        log_button.click()
        sleep(5)
    except Exception:
        print("unknown error")
        return


def get_state(state_name, these_users):
    these_states = these_users.list_collection_names()
    print(these_states)

    for state in these_states:
        # if x == "Connecticut":
        # if x == "Colorado":
        # if x == "Michigan":
        # if x == "New York":
        # if x == "Utah":
        # if x == "Montana":
        # if x == "Texas":
        # if x == "North Dakota":
        if state == state_name:
            return state


def love_picture(pic_link):
    driver.get(pic_link)
    sleep(1)
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    sleep(1)
    try:
        love_links = driver.find_elements(By.LINK_TEXT, "Love")
        num_comments = 0
        for love_link in love_links:
            driver.execute_script("arguments[0].click();", love_link)
            num_comments += 1
            sleep(0.2)
        print(f"liked {num_comments} comments")
    except Exception:
        print("ERROR CLICKING LINK")
        sleep(1.0)


def love_pictures(state, db_users):
    count = 0
    these_users = db_users[state].find({"jLikedPictures": False})

    for user in these_users:
        if count == 200:
            print("hit 200 quitting now")
            driver.quit()
            quit()
        if not user["gender"] == "M":
            count += 1
            print(
                "getting user ",
                user["userName"],
                "age ",
                user["age"],
                "gender ",
                user["gender"],
                "from state",
                user["state"],
            )
            try:
                driver.get(user["pictureLink"])
                sleep(1.0)
            except:
                print("unknown error, continue?")
                driver.quit()
                quit()
                sleep(1.0)

            picture_link_selector = my_selectors["picture_link_selector"]
            picture_elements = driver.find_elements(By.XPATH, picture_link_selector)

            picture_links = [el.get_attribute("href") for el in picture_elements]

            if len(picture_links) > 3:
                picture_links = [picture_links[x] for x in range(3)]

            try:
                driver.get(picture_links[0])
            except Exception:
                continue

            last_post = driver.find_element(
                By.XPATH, '//*[@id="ptr-main-element"]//div/main//a/time'
            ).text
            year = helpers.last_number_in_string(last_post)
            print(f"last post was {year}")

            if year > 2017 or year < 40:
                for picture_link in picture_links:
                    love_picture(picture_link)

                update_data(
                    db_users[state], "_id", user["_id"], "jLikedPictures", True, False
                )

            else:
                print("last post older than 2018, passing")
                update_data(
                    db_users[state], "_id", user["_id"], "inactiveAccount", True, False
                )

            update_data(
                db_users[state], "_id", user["_id"], "lastPicturePost", year, False
            )
