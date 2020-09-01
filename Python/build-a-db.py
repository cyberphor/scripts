#!/usr/bin/env python3

import os
import sqlite3

def build():
    name = input('[>] Database name: ')
    db = name + '.db'
    if not os.path.exists(db):
        connection = sqlite3.connect(db)
        cursor = connection.cursor()
        table_name = input('[>] Table name: ')
        column1_name = input('[>] Column name (1/3, TEXT): ')
        column2_name = input('[>] Column name (2/3, TEXT): ')
        column3_name = input('[>] Column name (3/3, INTEGER): ')
        column1_value = input("[>] {}: ".format(column1_name))
        column2_value = input("[>] {}: ".format(column2_name))
        column3_value = input("[>] {}: ".format(column3_name))
        table_attributes = table_name, column1_name, column2_name, column3_name
        row_attributes = table_name, column1_value, column2_value, column3_value
        read_attributes = column1_name, column2_name, column3_name, table_name
        create = "CREATE TABLE %s (%s TEXT, %s TEXT, %s INTEGER)" % (table_attributes)
        update = "INSERT INTO %s VALUES ('%s', '%s', '%s')" % (row_attributes)
        read = "SELECT %s, %s, %s FROM %s" % (read_attributes)
        #delete = ""
        cursor.execute(create)
        cursor.execute(update)
        records = cursor.execute(read).fetchall()
        #cursor.execute(delete)
        print(records)
    else:
        print('[x] Database already exists.')
        exit()

if __name__ == '__main__':
    build()

# REFERENCES
# https://www.digitalocean.com/community/tutorials/how-to-use-the-sqlite3-module-in-python-3
# https://linuxize.com/post/python-check-if-file-exists/ 
# https://stackoverflow.com/questions/39801441/can-i-use-a-variable-inside-of-an-input-statement
