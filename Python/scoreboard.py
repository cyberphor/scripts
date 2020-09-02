#!/usr/bin/env python3

import argparse
import hashlib
import os
import sqlite3

parser = argparse.ArgumentParser()
parser.add_argument('--create', action='store_true')
parser.add_argument('--add-player', action='store_true')
parser.add_argument('--add-points', action='store_true')
parser.add_argument('--scores', action='store_true')
args = parser.parse_args()

database = 'player.db'
connection = sqlite3.connect(database)
cursor = connection.cursor()
table1 = 'players' 
column1 = 'username' 
column2 = 'password' 
column3 = 'score' 

def api(action):
    cursor.execute(action)
    connection.commit()

def create():
    table = table1, column1, column2, column3
    create = "CREATE TABLE %s (%s TEXT, %s TEXT, %s INTEGER)" % (table)
    api(create)
    print('[+] Created scoreboard.')

def add_player():
    username = input('[>] Username: ')
    password = hashlib.sha512(input('[>] Password: ').encode('UTF-8')).hexdigest()
    score = input('[>] Score: ')
    record = table1, username, password, score
    add = "INSERT INTO %s VALUES ('%s', '%s', '%s')" % (record)
    api(add)
    print('[+] Added player: ')
    scores()

def scores():
    query = "SELECT username, score FROM players"
    records = cursor.execute(query).fetchall()
    for record in records:
        print(record)

def authenticated(player):
    password = hashlib.sha512(input('[>] Their password: ').encode('UTF-8')).hexdigest()
    query = "SELECT password FROM players WHERE username = ?"
    result = cursor.execute(query,(player,)).fetchall()
    if len(result) > 0:
        correct = result[0][0]
        if password == correct: return True
        else: return False

def get_points(player):
    query = "SELECT score FROM players WHERE username = ?"
    result = cursor.execute(query,(player,)).fetchall()[0][0]
    return result

def add_points():
    player = input('[>] Player: ')
    if authenticated(player) == True:
        new_points = input('[>] Points to add: ')
        old_points = get_points(player)
        # insert more code here
        print(" --> Added %s points to %s's score." % (new_points, player))
    else:
        print('[x] Invalid credentials.')

if __name__ == '__main__':
    if args.create: create()
    elif args.add_player: add_player()
    elif args.add_points: add_points()
    elif args.scores: scores()

# REFERENCES
# https://www.digitalocean.com/community/tutorials/how-to-use-the-sqlite3-module-in-python-3
# https://linuxize.com/post/python-check-if-file-exists/ 
# https://stackoverflow.com/questions/39801441/can-i-use-a-variable-inside-of-an-input-statement
