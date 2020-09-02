#!/usr/bin/env python3

import argparse
import os
import sqlite3

parser = argparse.ArgumentParser()
parser.add_argument('--create', action='store_true')
parser.add_argument('--add-player', action='store_true')
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
    password = input('[>] Password: ')
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

if __name__ == '__main__':
    if args.create: create()
    elif args.add_player: add_player()
    elif args.scores: scores()

# REFERENCES
# https://www.digitalocean.com/community/tutorials/how-to-use-the-sqlite3-module-in-python-3
# https://linuxize.com/post/python-check-if-file-exists/ 
# https://stackoverflow.com/questions/39801441/can-i-use-a-variable-inside-of-an-input-statement
