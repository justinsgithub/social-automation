from datetime import datetime
import json
from typing import Any, Dict, TypedDict
from pymongo import MongoClient
from pymongo.collection import Collection



class TypeMember(TypedDict):
    username: str
    page_url: str
    age: int
    role: str
    gender: str
    location: str
    orientation: str
    friend_count: int
    follower_count: int
    following_count: int
    picture_count: int
    active: str
    looking_for: list[str]
    roles: list[str]
    relationships: list[str]
    ds_relationships: list[str]
    latest_activity: datetime

CLIENT: MongoClient[TypeMember] = MongoClient('mongodb://localhost:27017')

DB = CLIENT.ali

class Member:
    collection: Collection[TypeMember] = DB.members
    def __init__(self):
        return

    @staticmethod
    def all():
        return list(Member.collection.find({}, limit=100))

    @staticmethod
    def find_by_page(page_url: str):
        return Member.collection.find_one({page_url: page_url})

    def save(self, member: TypeMember):
        with open(member['username'], 'w+') as file:
            file.write(json.dumps(member))
        return
