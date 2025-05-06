
CREATE TABLE Users (
    id UUID PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    signup_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    home_town VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE Location (
    id UUID PRIMARY KEY,
    city VARCHAR(50),
    province VARCHAR(50),
    station VARCHAR(50),
    location_type VARCHAR(20) CHECK (location_type IN ('airport', 'terminal', 'trainstation'))
);

CREATE TABLE Services (
    id UUID PRIMARY KEY,
    flatbed_wagon BOOLEAN DEFAULT FALSE,
    catering_services BOOLEAN DEFAULT FALSE,
    wifi_access BOOLEAN DEFAULT FALSE,
    air_conditioning BOOLEAN DEFAULT FALSE
);


CREATE TABLE Vehicle (
    id UUID PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    service UUID REFERENCES Services(id),
    company UUID REFERENCES Company(id),
    type VARCHAR(50)
);

CREATE TABLE Ticket (
    id UUID PRIMARY KEY,
    origin UUID NOT NULL REFERENCES Location(id) ON DELETE CASCADE,
    destination UUID NOT NULL REFERENCES Location(id) ON DELETE CASCADE,
    start_at TIMESTAMP NOT NULL,
    duriation INTERVAL NOT NULL,
    delay INTERVAL DEFAULT NULL,
    class VARCHAR(20) CHECK (class IN ('economic', 'VIP', 'business')),
    vehicle UUID NOT NULL REFERENCES Vehicle(id) ON DELETE CASCADE,
    catering TEXT,
    is_canceld BOOLEAN
);

CREATE TABLE Seat (
    id UUID PRIMARY KEY,
    start_number VARCHAR(50) NOT NULL,
    end_number INT NOT NULL CHECK (end_number > 0),
    ticket UUID REFERENCES Ticket(id),
    price INT CHECK (price > 0)
);

CREATE TABLE Transaction (
    id UUID PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    paid_amount INT NOT NULL CHECK (paid_amount >= 0),
    tracking_code VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Reservation (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    seat UUID REFERENCES Seat(id),
    seat_number VARCHAR(50),
    transaction UUID DEFAULT NULL REFERENCES Transaction(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_cancelled BOOLEAN DEFAULT FALSE
);

CREATE TABLE Report (
    id UUID PRIMARY KEY,
    subject VARCHAR(50) CHECK (subject IN ('Payments', 'Tickets', 'Delays', 'Other')),
    description TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    inspector UUID NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    is_proccessed BOOLEAN DEFAULT FALSE,
    proccessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
