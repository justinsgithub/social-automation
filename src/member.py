from datetime import datetime
import json
from typing import Any, Dict, NotRequired, TypedDict
from pymongo import MongoClient
from pymongo.collection import Collection
from bson import ObjectId
import models
from rich import print

from my_secrets import MONGO_URI



class TypeMember(TypedDict):
    _id: NotRequired[ObjectId]
    # uid: str
    username: str
    page_url: str
    pictures_page_url: NotRequired[str]
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
    last_activity: datetime

CLIENT: MongoClient[TypeMember] = MongoClient(MONGO_URI)

DB = CLIENT.ali

MEMBERS: Collection[TypeMember] = DB.members

class Member:
    def __init__(self, page_url: str):
        self.page_url = page_url

    @staticmethod
    def all():
        return list(MEMBERS.find({}, limit=5))

    @staticmethod
    def no_role():
        return list(MEMBERS.find({"role": {"$exists": False}}, limit=500))

    @staticmethod
    def find_by_page(page_url: str):
        member = MEMBERS.find_one({"page_url": page_url})
        return member
    
    def get_member_data(self) -> TypeMember | None:
        page_data = models.ProfilePage(self.page_url)
        if 'File Not Found' in page_data.title:
            return None
        if "isn't available" in page_data.title:
            return None
        member_data = TypeMember(
                                username=page_data.username,
                                page_url=self.page_url,
                                age=page_data.age,
                                role=page_data.role,
                                gender=page_data.gender,
                                location=page_data.location,
                                orientation=page_data.orientation,
                                friend_count=page_data.friend_count,
                                follower_count=page_data.follower_count,
                                following_count=page_data.following_count,
                                picture_count=page_data.picture_count,
                                active=page_data.active,
                                looking_for=page_data.looking_for,
                                roles=page_data.roles,
                                relationships=page_data.relationships,
                                ds_relationships=page_data.ds_relationships,
                                last_activity=page_data.last_activity,
                                 )
        return member_data

    def update(self):
        member_data = self.get_member_data()
        if member_data:
            result = MEMBERS.update_one({"page_url": self.page_url}, {"$set" : member_data}, upsert=True)
            print(result)
        else:
            print('PAGE NOT FOUND OR IS NOT AVAILABLE, DELETING', self.page_url)
            result = MEMBERS.delete_one({"page_url": self.page_url})
            print(result)

members = Member.no_role()

for member in members:
    print(member)
    member_object = Member(member['page_url'])
    member_object.update()
