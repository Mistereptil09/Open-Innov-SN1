CREATE DATABASE IF NOT EXISTS basketball DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE basketball;

START TRANSACTION;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS Shots;
DROP TABLE IF EXISTS Performance;
DROP TABLE IF EXISTS PlayerAwards;
DROP TABLE IF EXISTS TeamAwards;
DROP TABLE IF EXISTS PlayerMatchParticipation;
DROP TABLE IF EXISTS PlayerTeam;
DROP TABLE IF EXISTS Players;
DROP TABLE IF EXISTS PlayerPositions;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Teams;
DROP TABLE IF EXISTS Tournaments;
DROP TABLE IF EXISTS TeamTournamentParticipation;
DROP TABLE IF EXISTS Contracts;

-- Drop existing indexes if they exist
DROP INDEX idx_match_date ON Matches;
DROP INDEX idx_player_name ON Players;
DROP INDEX idx_player_team ON PlayerTeam;
DROP INDEX idx_player_match ON PlayerMatchParticipation;
DROP INDEX idx_performance ON Performance;
DROP INDEX idx_shot ON Shots;
DROP INDEX idx_contract ON Contracts;

-- Create tables and indexes
CREATE TABLE Teams (
    team_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(191) UNIQUE
);

CREATE TABLE Matches (
    match_id INT PRIMARY KEY AUTO_INCREMENT,
    match_date DATE NOT NULL,
    winner INT NOT NULL,
    team1_id INT NOT NULL,
    team2_id INT NOT NULL,
    team1_score INT NOT NULL,
    team2_score INT NOT NULL,
    overtime BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (team1_id) REFERENCES Teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (team2_id) REFERENCES Teams(team_id) ON DELETE CASCADE
);

-- Index creation with shortened length to avoid exceeding the maximum key length
CREATE INDEX idx_match_date ON Matches(match_date);

CREATE TABLE PlayerPositions (
    position_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(191) UNIQUE
);

CREATE TABLE Players (
    player_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(191) NOT NULL,
    birth_date DATE NOT NULL,
    weight DECIMAL(5, 2) NOT NULL,
    height DECIMAL(5, 2) NOT NULL,
    draft_year YEAR,
    origin VARCHAR(191) NOT NULL
);

-- Shortened name index length
CREATE INDEX idx_player_name ON Players(name(100));

CREATE TABLE PlayerTeam (
    player_team_id INT PRIMARY KEY AUTO_INCREMENT,
    start_date DATE NOT NULL,
    end_date DATE DEFAULT NULL, 
    jersey_number INT NOT NULL,
    player_id INT NOT NULL,
    team_id INT NOT NULL,
    position_id INT NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (player_id) REFERENCES Players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (position_id) REFERENCES PlayerPositions(position_id)
);

-- Shortened composite index length
CREATE INDEX idx_player_team ON PlayerTeam(player_id, team_id);

CREATE TABLE PlayerMatchParticipation (
    participation_id INT PRIMARY KEY AUTO_INCREMENT,
    player_team_id INT NOT NULL,
    match_id INT NOT NULL,
    FOREIGN KEY (player_team_id) REFERENCES PlayerTeam(player_team_id) ON DELETE CASCADE,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id) ON DELETE CASCADE
);

-- Adjusted length for composite index
CREATE INDEX idx_player_match ON PlayerMatchParticipation(player_team_id, match_id);

CREATE TABLE Awards (
    award_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(191) UNIQUE NOT NULL
);

CREATE TABLE TeamAwards (
    team_award_id INT PRIMARY KEY AUTO_INCREMENT,
    team_id INT NOT NULL,
    award_id INT NOT NULL,
    award_year YEAR NOT NULL,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (award_id) REFERENCES Awards(award_id) ON DELETE CASCADE
);

CREATE TABLE PlayerAwards (
    player_award_id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT NOT NULL,
    award_id INT NOT NULL,
    award_year YEAR NOT NULL,
    FOREIGN KEY (player_id) REFERENCES Players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (award_id) REFERENCES Awards(award_id) ON DELETE CASCADE
);

CREATE TABLE Performance (
    performance_id INT PRIMARY KEY AUTO_INCREMENT,
    player_team_id INT NOT NULL,
    match_id INT NOT NULL,
    play_time INT NOT NULL,
    defensive_rebounds INT NOT NULL,
    offensive_rebounds INT NOT NULL,
    assists INT NOT NULL,
    turnovers INT NOT NULL,
    personal_fouls INT NOT NULL,
    steals INT NOT NULL,
    blocks INT NOT NULL,
    team_id INT NOT NULL,
    FOREIGN KEY (player_team_id) REFERENCES PlayerTeam(player_team_id) ON DELETE CASCADE,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE CASCADE
);

-- Adjusted composite index length
CREATE INDEX idx_performance ON Performance(player_team_id, match_id, team_id);

CREATE TABLE Shots (
    shot_id INT PRIMARY KEY AUTO_INCREMENT,
    performance_id INT NOT NULL,
    distance DECIMAL(5, 2) NOT NULL,
    defender INT,
    time_shot TIME NOT NULL,
    shot_result BOOLEAN NOT NULL,
    free_throw BOOLEAN NOT NULL,
    FOREIGN KEY (performance_id) REFERENCES Performance(performance_id) ON DELETE CASCADE,
    FOREIGN KEY (defender) REFERENCES Players(player_id) ON DELETE SET NULL
);

-- Shortened index length
CREATE INDEX idx_shot ON Shots(performance_id, defender);

CREATE TABLE Tournaments (
    tournament_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(191) UNIQUE
);

CREATE TABLE TeamTournamentParticipation (
    participation_id INT PRIMARY KEY AUTO_INCREMENT,
    team_id INT NOT NULL,
    tournament_id INT NOT NULL,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (tournament_id) REFERENCES Tournaments(tournament_id) ON DELETE CASCADE
);

CREATE TABLE Contracts (
    contract_id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT NOT NULL,
    team_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    salary DECIMAL(10, 2),
    FOREIGN KEY (player_id) REFERENCES Players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE CASCADE
);

-- Shortened composite index length
CREATE INDEX idx_contract ON Contracts(player_id, team_id);

COMMIT;

START TRANSACTION;

-- insert data
INSERT INTO PlayerPositions (name)
VALUES
    ('Point Guard'),
    ('Shooting Guard'),
    ('Small Forward'),
    ('Power Forward'),
    ('Center');

INSERT INTO Teams (name) 
VALUES
    ('Los Angeles Lakers'),
    ('Golden State Warriors'),
    ('Brooklyn Nets'),
    ('Miami Heat'),
    ('Oklahoma City Thunder');

INSERT INTO Players (name, birth_date, weight, height, draft_year, origin) 
VALUES 
    ('LeBron James', '1984-12-30', 250, 6.8, 2003, 'Akron, Ohio'),
    ('Stephen Curry', '1988-03-14', 185, 6.3, 2009, 'Akron, Ohio'),
    ('Kevin Durant', '1988-09-29', 240, 6.9, 2007, 'Washington, D.C.'),
    ('Kobe Bryant', '1978-08-23', 212, 6.6, 1996, 'Philadelphia, Pennsylvania'),
    ('Dwyane Wade', '1982-01-17', 220, 6.4, 2003, 'Chicago, Illinois');

INSERT INTO PlayerTeam (start_date, jersey_number, player_id, team_id, position_id)
VALUES
    ('2020-01-01', 23, 1, 1, 3),
    ('2020-01-01', 30, 2, 2, 1),
    ('2020-01-01', 7, 3, 3, 3),
    ('2020-01-01', 24, 4, 4, 2),
    ('2020-01-01', 3, 5, 5, 1);

COMMIT;