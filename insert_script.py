import psycopg2
from faker import Faker
import uuid
import random
import bcrypt

conn = psycopg2.connect(
    dbname="postgres",
    user="funlife",
    password="%%$)$$$()*&",
    host="localhost",
    port="5432"
)

cur = conn.cursor()
faker = Faker()


user_ids = []
admin_ids = []
location_ids = []
service_ids = []
vehicle_ids = {}
seat_ids = {}

# create users
for _ in range(10):
    user_id = str(uuid.uuid4())
    username = faker.user_name()
    password = faker.password(length=12)
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    email = faker.unique.email()
    is_admin = random.choice([True, False])

    if is_admin:
        admin_ids.append(user_id)
    else:
        user_ids.append(user_id)

    home_town = faker.city()
    is_active = random.choice([True, False])

    cur.execute("""
        INSERT INTO Users (
            id, Username, Password, email, is_admin, home_town, is_active
        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (user_id, username, hashed_password, email, is_admin, home_town, is_active))

for _ in range(10):
    user_id = str(uuid.uuid4())
    username = faker.user_name()
    password = faker.password(length=12)
    email = faker.unique.email()

    is_admin = random.choice([True, False])
    if is_admin == True:
        admin_ids.append(user_id)
    else:
        user_ids.append(user_id)

    home_town = faker.city()
    is_active = random.choice([True, False])

    cur.execute("""
        INSERT INTO Users (
            id, Username, Password, email, is_admin, home_town, is_active
        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (user_id, username, password, email, is_admin, home_town, is_active))


# create locations

location_types = ['airport', 'terminal', 'trainstation']

for _ in range(50):
    location_id = str(uuid.uuid4())
    location_ids.append(location_id)

    city = faker.city()
    province = faker.state()
    station = faker.company()
    location_type = random.choice(location_types)

    cur.execute("""
        INSERT INTO Location (
            id, city, Province, station, location_type
        ) VALUES (%s, %s, %s, %s, %s)
    """, (location_id, city, province, station, location_type))

# create services
service_ids = []
for _ in range(10):
    service_id = str(uuid.uuid4())
    service_ids.append(service_id)
    cur.execute("""
        INSERT INTO Services (
            id, flatbed_wagon, catering_services, wifi_access, air_conditioning
        ) VALUES (%s, %s, %s, %s, %s)
    """, (
        service_id,
        random.choice([True, False]),
        random.choice([True, False]),
        random.choice([True, False]),
        random.choice([True, False])
    ))


# create vechile
for _ in range(5):
    vehicle_id = str(uuid.uuid4())
    capacity = random.randint(10, 300)
    vehicle_ids[vehicle_id] = capacity
    name = faker.word().capitalize() + " " + faker.word().capitalize()
    service_id = random.choice(service_ids)
    vehicle_type = random.choice(["bus", "train", "plane"])

    cur.execute("""
        INSERT INTO Vehicle (
            id, name, capacity, service, type
        ) VALUES (%s, %s, %s, %s, %s)
    """, (
        vehicle_id, name, capacity, service_id, vehicle_type
    ))


ticket_classes = ['economic', 'VIP', 'business']
catering_options_pool = ['meal', 'snack', 'drink', 'dessert']

# Create Tickets
for _ in range(10):
    ticket_id = str(uuid.uuid4())
    origin, destination = random.sample(location_ids, 2)
    start_at = faker.date_time_between(start_date="now", end_date="+30d")
    duration = f"{random.randint(1, 10)} hours"
    delay = f"{random.randint(0, 3)} hours" if random.random() < 0.3 else None
    ticket_class = random.choice(ticket_classes)
    vehicle_id = random.choice(list(vehicle_ids.keys()))
    catering = random.sample(catering_options_pool, k=random.randint(0, 3))
    is_canceled = random.choice([True, False])
    created_at = faker.date_time_between(start_date="-10d", end_date="now")

    if is_canceled == True:
        who_canceled = random.choice(admin_ids)
    else:
        who_canceled = None

    cur.execute("""
        INSERT INTO Ticket (
            id, origin, destination, start_at, duriation, delay,
            class, vehicle, catering, is_canceld
        ) VALUES (
            %s, %s, %s, %s, %s, %s,
            %s, %s, %s, %s
        )
    """, (
        ticket_id, origin, destination, start_at, duration, delay,
        ticket_class, vehicle_id, catering, is_canceled
    ))

    # Create Seat
    capacity = vehicle_ids[vehicle_id]
    a = random.randint(1, capacity - 2)
    b = random.randint(1, capacity - a - 1)
    c = capacity - a - b
    seat_nums = [a,b,c]

    for i in range(3):
        seat_id = str(uuid.uuid4())
        start_number = (seat_nums[i-1] + 1) if i != 0 else 1
        end_number = seat_nums[i] + start_number
        seat_ids[seat_id] = {'start': start_number, 'end': end_number, 'created_at': created_at}
        price = random.randint(1000, 100000)

        cur.execute("""
            INSERT INTO Seat (
                id, start_number, end_number, price, ticket
            ) VALUES (%s, %s, %s, %s, %s)
        """, (
            seat_id, start_number, end_number, price, ticket_id
        ))


# Create Reservations
for _ in range(20):
    reservation_id = str(uuid.uuid4())
    user_id = random.choice(user_ids)
    seat_id = random.choice(list(seat_ids.keys()))
    print(seat_ids[seat_id]['start'], seat_ids[seat_id]['end'])
    seat_number = str(random.randint(seat_ids[seat_id]['start'], seat_ids[seat_id]['end']))
    is_cancelled = random.choice([True, False])
    created_at = faker.date_time_between(start_date=seat_ids[seat_id]['created_at'], end_date="now")

    cur.execute("""
        INSERT INTO Reservation (
            id, user_id, seat, seat_number, is_cancelled
        ) VALUES (%s, %s, %s, %s, %s)
    """, (
        reservation_id, user_id, seat_id, seat_number, is_cancelled
    ))

conn.commit()
cur.close()
conn.close()
