#!/usr/bin/env python3

import argparse
import code
import hashlib
import os
import sqlite3

class game():
    def __init__(self,args):
        if args.use_scoreboard:
            if os.path.exists(args.use_scoreboard):
                self.scoreboard = args.use_scoreboard
            else:
                print('[x] CTF scoreboard not found.')
                exit()
        elif args.create_scoreboard:
            if os.path.exists(args.create_scoreboard) == False:
                self.scoreboard = args.create_scoreboard
            else:
                print('[x] CTF scoreboard already exists.')
                exit()
        else: 
            self.scoreboard = 'scoreboard.sqlite'
        self.connection = sqlite3.connect(self.scoreboard)
        self.cursor = self.connection.cursor()
        if self.scoreboard_exists() == False:
            create_table = '''CREATE TABLE scoreboard
                (username TEXT, password TEXT,
                score INTEGER, solved BLOB)'''
            self.api(create_table,None)
        self.authenticated = False
        self.username = ''
        self.admin = self.administrator(args)
        self.get = self.admin.get_challenge
        self.data = self.admin.get_challenge_data

    def api(self,action,parameters):
        if parameters == None:
            records = self.cursor.execute(action).fetchall()
        else:
            records = self.cursor.execute(action,parameters).fetchall()
        keywords = ['CREATE','INSERT','UPDATE','DELETE']
        if any(trigger in action for trigger in keywords): 
            self.connection.commit()
        else:
            return records

    def scoreboard_exists(self):
        query = '''SELECT count(name) FROM sqlite_master 
            WHERE type = "table" and name = "scoreboard"'''
        records = self.api(query,None)[0][0]
        if records > 0:
            return True
        else:
            return False

    def add_player(self,username,password):
        if len(self.get_player(username)) == 0:
            add = '''INSERT INTO scoreboard VALUES (?, ?, ?, ?)'''
            password = hashlib.sha512(password.encode('UTF-8')).hexdigest()
            score = 0
            solved = str([])
            record = (username, password, score, solved)
            self.api(add,record)
            return '[+] Added %s to the scoreboard.' % (username)
        else: 
            return '[x] The username %s is already taken.' % (username)

    def get_player(self,username):
        query = '''SELECT username, score, solved FROM scoreboard 
            WHERE username = ?'''
        username = (username,)
        record = self.api(query,username)
        return record

    def correct_password(self,username,password):
        query = '''SELECT password FROM scoreboard 
            WHERE username = ?'''
        password = hashlib.sha512(password.encode('UTF-8')).hexdigest()
        username = (username,)
        record = self.api(query,username)
        if record:
            if password == record[0][0]: 
                return True
            else:
                return False

    def login(self,username,password):
        if len(self.get_player(username)) != 0:
            if self.correct_password(username,password) == True:
                self.authenticated = True
                self.username = username
                return ('[+] %s has entered the game.' % (self.username))
        else:
            return '[x] Invalid credentials.'

    def logout(self):
        if self.authenticated == True:
            self.authenticated = False
            self.username = ''
            return '[+] Successfully logged-out.'
        else:
            return '[x] Please login first.'

    def remove_player(self,username,password):
        if self.authenticated == False:
            if self.correct_password(username,password) == True:
                delete = '''DELETE FROM scoreboard
                    WHERE username = ?'''
                username = (username,)
                self.api(delete,username)
                return '[+] Removed %s from the scoreboard.' % (username)
            else:
                return '[x] Invalid credentials.'
        else:
            return '[x] Please logout first.'

    def scores(self):
        query = '''SELECT username, score, solved FROM scoreboard'''
        records = self.api(query,None)
        scoreboard = sorted(records, key = lambda x: x[1], reverse = True)
        for player in scoreboard:
            username = player[0]
            score = player[1]
            solved = player[2]
            print(score, '\t', username, '\t', solved)

    def solve(self,number,answer):
        if self.authenticated == True:
            solved = eval(self.get_player(self.username)[0][2])
            if number not in solved:
                attempt, points = self.admin.get_solution(number,answer)
                if attempt == True:
                    update = '''UPDATE scoreboard SET solved = ?, score = ?
                        WHERE username = ?'''
                    solved.append(number)
                    score = self.get_player(self.username)[0][1] + points
                    record = (str(solved),score,self.username)
                    self.api(update,record)
                    return '[+] Correct!'
                elif attempt == False:
                    return '[x] Incorrect.'
                else:
                    return attempt
            else:
                return '[x] You have already solved this challenge.'
        else:
            return '[x] Please login first.'
    
    class administrator():
        def __init__(self,args):
            if args.use_database and os.path.exists(args.use_database):
                self.database = args.use_database
            elif args.create_database:
                if os.path.exists(args.create_database) == False:
                    self.database = args.create_database
                else:
                    print('[x] CTF database already exists.')
                    exit()
            elif os.path.exists('challenges.sqlite'):
                self.database = 'challenges.sqlite'
            else:
                print('[x] CTF database not found.')
                exit()
            self.connection = sqlite3.connect(self.database)
            self.cursor = self.connection.cursor()
            if self.challenges_exist() == False:
                create_table = '''CREATE TABLE challenges 
                    (number INTEGER, points INTEGER, challenge TEXT, 
                    data TEXT, data_type TEXT, 
                    solution TEXT, solution_type TEXT)'''
                self.api(create_table,None)
            if args.add_challenges:
                self.add_game_file(args.add_challenges)
                exit()
       
        def api(self,action,parameters):
            if parameters == None:
                records = self.cursor.execute(action).fetchall()
            else:
                records = self.cursor.execute(action,parameters).fetchall()
            keywords = ['CREATE','INSERT','UPDATE','DELETE']
            if any(trigger in action for trigger in keywords): 
                self.connection.commit()
            else:
                return records

        def challenges_exist(self):
            query = '''SELECT count(name) FROM sqlite_master 
                WHERE type = "table" and name = "challenges"'''
            records = self.api(query,None)[0][0]
            if records > 0:
                return True
            else:
                return False

        def get_challenge(self,number):
            query = '''SELECT challenge FROM challenges 
                WHERE number = ?'''
            number = (number,)
            record = self.api(query,number)
            if len(record) > 0:
                return record[0][0]
            else: 
                return record

        def get_challenge_data(self,number):
            query = '''SELECT data, data_type FROM challenges 
                WHERE number = ?'''
            number = (number,)
            record = self.api(query,number)
            if len(record) > 0:
                if record[0][1] != 'str':
                    return eval(record[0][0])
                else:
                    return record[0][0]
            else:
                return record

        def add_challenge(self,number,points,challenge,data,solution):
            if len(self.get_challenge(number)) == 0:
                add = '''INSERT INTO challenges VALUES 
                    (?, ?, ?, ?, ?, ?, ?)'''
                data_type = type(data).__name__
                data = str(data)
                solution_type = type(solution).__name__
                solution = str(solution)
                record = (number,points,challenge,
                    data,data_type,solution,solution_type)
                self.api(add,record)
                return True
            else: 
                return False

        def add_game_file(self,filename):
            if os.path.exists(filename):
                with open(filename) as filedata:
                    new = [] 
                    existed = []
                    for line in filedata.readlines():
                        if line[0] != '#':
                            if self.add_challenge(*eval(line)) == True:
                                new.append(line[0])
                            else:
                                existed.append(line[0])
                    print('[+] Added %s CTF challenges.' % (len(new)))
                    if len(existed) > 0:
                        print(' --> %s already existed.' % (','.join(existed)))

        def get_solution(self,number,answer):
            if len(self.get_challenge(number)) > 0:
                query = '''SELECT solution, solution_type, points 
                    FROM challenges WHERE number = ?'''
                number = (number,)
                record = self.api(query,number)
                points = record[0][2]
                if record[0][1] != 'str':
                    solution = eval(record[0][0])
                else:
                    solution = record[0][0]
                if answer == solution:
                    return True, points
                else:
                    return False, 0
            else:
                return ('[x] Challenge #%s does not exist.' % (number)), 0

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--create-scoreboard')
    parser.add_argument('--use-scoreboard','-s')
    parser.add_argument('--create-database')
    parser.add_argument('--use-database','-d')
    parser.add_argument('--event-name','-e')
    parser.add_argument('--add-challenges','-a')
    args = parser.parse_args()
    dashes = '-----------------------------------'
    motd = '[+] Welcome to the YellowTeam CTF!'
    banner = '\n'.join([dashes,motd,dashes])
    ctf = game(args)
    code.interact(banner=banner,local=locals())

if __name__ == '__main__':
    main()

# REFERENCES
# https://stackoverflow.com/questions/3389574/check-if-multiple-strings-exist-in-another-string
# https://stackoverflow.com/questions/19112735/how-to-print-a-list-of-tuples-with-no-brackets-in-python
# https://stackoverflow.com/questions/36955553/sorting-list-of-lists-by-the-first-element-of-each-sub-list
# https://www.programiz.com/python-programming/methods/built-in/sorted
# https://www.thepythoncode.com/article/create-reverse-shell-python
