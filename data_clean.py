# -*- coding: utf-8 -*-
"""
Created on Wed Mar 23 00:48:27 2016

@author: Xuyan Xiao
"""
import csv

#import os
#os.chdir("C:\\Users\\oweni\\Downloads")

#uncomment this part if you want to use the 2009 date
#sr311 = open("311_Service_Requests_for_2009.csv","r")
#clean = open("311_2009_clean.csv","w")

sr311 = open("311_Service_Requests_from_2010_to_Present.csv","r")
clean = open("311_2010_clean.csv","w")

header = sr311.readline()
header = header.strip("\n").split(",")

features = ["Created Date","Closed Date","Agency","Complaint Type","Location Type",
            "Incident Zip","City","Resolution Action Updated Date","Latitude","Longitude"]

indices = []

for ind,item in enumerate(header):
    if item in features:
        indices.append(ind)

clean.write(",".join(features)+"\n")

cnt = 0

for line in sr311:
    line = line.strip("\n")
    line = csv.reader([line],skipinitialspace=True)
    line = line.next()
    write = []
    for i in indices:
        tmp = line[i]
#        keep the date only 
        if i in [indices[0],indices[1],indices[7]]:
            tmp = line[i][0:10]
        write.append(str(tmp))
    if write[-1] != '' and write[-2] != '':
        clean.write(",".join(write)+"\n")

#    I use the first 1000 rows for test and it turned out successful
#        cnt+=1
#    if cnt == 1000:
#        break

sr311.close()
clean.close()