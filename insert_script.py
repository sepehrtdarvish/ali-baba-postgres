import psycopg2
from faker import Faker
import uuid
import random

conn = psycopg2.connect(
    dbname="",
    user="",
    password="",
    host="localhost",
    port="5432"
)

cur = conn.cursor()
faker = Faker()

for _ in range(1000):
    user_id = str(uuid.uuid4())
    username = faker.user_name()
    password = faker.password(length=12)
    email = faker.unique.email()
    is_admin = random.choice([True, False])
    home_town = faker.city()
    is_active = random.choice([True, False])

    cur.execute("""
        INSERT INTO "User" (
            id, "Username", "Password", email, is_admin, home_town, is_active
        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (user_id, username, password, email, is_admin, home_town, is_active))

conn.commit()
cur.close()
conn.close()