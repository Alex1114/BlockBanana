#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import csv

path = 'BAYC-Holder-0314.txt'

address = []

with open(path) as f:
    for line in f.readlines():
        s = line.split("\n")
        address.append("\'" + str(s[0]).lower() + "\'")


print(address)

with open('BAYC-Holder-0314.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(address)