from selenium.webdriver.common.by import By
import undetected_chromedriver as uc
from random import randint
from time import sleep
from pymongo import MongoClient
from fastapi import FastAPI
from rich import print
from pymongo import MongoClient
import typer

# app = FastAPI()

app = typer.Typer()

mongodb_client = MongoClient('mongodb+srv://justinaawd:justinaawdblah@online-presence-cluster.rdnj4.mongodb.net/ali?retryWrites=true&w=majority')
database = mongodb_client['ali']
print("Connected to the MongoDB database!")
members = list(database['members'].find(limit=500))
print(members)

driver = uc.Chrome(user_data_dir="selenium/luvdaddy95")

driver.maximize_window()

driver.get('https://fetlife.com/home')

# driver.find_element(By.XPATH, '/html/body/div[3]/div/div[3]/div/main/div/div[1]/form/div[1]/div[1]/div/div/input').send_keys('luvdaddy95')
#
# driver.find_element(By.XPATH, '/html/body/div[3]/div/div[3]/div/main/div/div[1]/form/div[1]/div[2]/div/div/input').send_keys('Hockey1343$$')
#
# driver.find_element(By.ID, 'remember_me').click()
#
# driver.find_element(By.XPATH, '/html/body/div[3]/div/div[3]/div/main/div/div[1]/form/div[2]/button').click()

count = 0

for member in members:
    try:
        driver.get(member['page_url'])
        count += 1 
        print('GOT ' + str(count) + ' MEMBERS')
        sleep(randint(5, 10))
        print(member)
    except Exception as e:
        print(f'[bold red]{e}[/bold red]')
        continue
    else:
        continue
