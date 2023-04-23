#!/usr/bin/python

import socket
import time
import uuid
import csv
import io
import os
import argparse
import subprocess
from subprocess import Popen, PIPE
from header import printHeader
import re

# ip = "codeserverbwn.duckdns.org"
port = 4059
retry = 1
delay = 0.05
timeout = 1

data = list()
tailingFilename = str(uuid.uuid4())

folder_name = 'output'
# Create the folder, skip if exists
if not os.path.exists(folder_name):
    os.makedirs(folder_name)

pingcount = 4
telnetretry = 4
filename = ""


def read_cmd_args():
    # Read command line arguments with python2
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--file", help="File name to read from")
    parser.add_argument("-pc", "--packet_counts", help="Number of packets")
    parser.add_argument("-tr", "--telnet_retries", help="Telnet retries")

    args = parser.parse_args()
    return args


def isOpen(ip, port):
    s = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
    s.settimeout(timeout)
    try:
        s.connect((ip, int(port), 0, 0))
        s.shutdown(socket.SHUT_RDWR)
        return True
    except BaseException:
        return False
    finally:
        s.close()


def pingStatistics(ip):
    print "  > GETTING STATISTICS FOR [ ", ip, " ]"

    try:
        command = "ping6 -W 1 -c " + pingcount + " " + ip
        process = Popen(command, stdout=PIPE, stderr=None, shell=True)
        output = process.communicate()[0]

        regex = r"rtt min\/avg\/max\/mdev = ([.0-9]+)\/([.0-9]+)\/([.0-9]+)\/(.*)$"
        regex_per_loss = r"(\d+%)"
        stats = list()
        # min, avg, max, mdev
        for block in re.findall(regex, output, re.S):
            stats.append(block[0])
            stats.append(block[1])
            stats.append(block[2])
            stats.append(block[3].strip('\n'))
        loss = re.search(regex_per_loss, output).group(1)
        stats.append(loss)
        print "  > STATISTICS FOR [ ", ip, " ]  ==>  ", stats
        if loss == '100%':
            return ['HOST_DOWN', 'HOST_DOWN', 'HOST_DOWN', 'HOST_DOWN', loss]
        else:
            return stats

    except BaseException:
        print('  > STATISTCS_FAILURE')


def pingSuccess(ip):
    hostname = ip
    # -i for duration, -c for packet count
    response = os.system("ping6 -W 1 -c " + pingcount + " " + hostname)
    if response == 0:
        return 0
    else:
        return -1


def checkHost(ip, port):
    lst = list()
    ipup = False
    ping = True

    if pingSuccess(ip) == 0:
        for i in range(retry):
            print('=> ping success')

            for x in range(1, telnetretry + 1):
                telnetStatus = isOpen(ip, port)
                if x != 1:
                    print "[ ! WARN !   Retrying telnet (", x, ")...  ]"
                if telnetStatus:
                    ipup = True
                    break
                else:
                    time.sleep(delay)
            """ if isOpen(ip, port):
                ipup = True
                break
            else:
                time.sleep(delay) """
    else:
        ping = ipup = False

    if ping:
        lst.append("PING SUCCESS")
    else:
        lst.append("PING FAIL")
    if ipup:
        lst.append("PORT OPEN")
    else:
        lst.append("PORT CLOSED")

    if ping:
        # Collect ping statistics only when the host is up
        lst.append(pingStatistics(ip))
    else:
        lst.append(['--', '--', '-', '--', '100%'])
    """ lst.append(ping)
    lst.append(ipup) """
    return lst


def readFromCSV(filename):
    with io.open(filename + '.csv', newline='') as f:
        reader = csv.reader(f)
        data.append(list(reader))
    f.close()


def preprocess(s):
    return bytes(s)

# BELOW TWO FUNCTIONS CONVERT THE OUTPUT TXT TO CSV


def getFileData():
    with io.open(os.path.join(folder_name, "Results_" + tailingFilename + ".txt"), 'r', newline='') as flhndl:
        return flhndl.readlines()


def extractToCSV(listData):
    header = ['HOST IP', 'PING STATUS', 'TELNET STATUS',
              'MIN', 'MAX', 'AVG', 'LATENCY', 'LOSS %']
    with io.open(os.path.join(folder_name, "Output_ResultsCSV_" + tailingFilename + ".csv"), 'wb') as myfile:
        wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
        wr.writerow(header)
        for lines in listData:
            temp = str(lines[0:len(lines) - 1])
            first = temp.split('\t')
            print("{}".format(first))

            wr.writerow(first)


args = read_cmd_args()
# Parse the cmd args and store them in the variables
pingcount = args.packet_counts
telnetretry = args.telnet_retries
filename = args.file

if not args.packet_counts:
    pingcount = raw_input("ENTER PACKET COUNTS: ")
if not args.telnet_retries:
    telnetretry = int(raw_input("ENTER TELNET RETRIES: "))
if not args.file:
    filename = raw_input(
        "ENTER THE FILE NAME WITHOUT THE EXTENSION (DEFAULT FORMAT CSV):  ")
    print(filename)

readFromCSV(filename)
with io.open(os.path.join(folder_name, "Results_" + tailingFilename + ".txt"), 'w', newline='') as file:
    for ips in data:
        for index, ips_get in enumerate(ips):
            print "[ ```````````````````````````````````````````` ]"
            print("[ RUN {} ]".format(index + 1))
            get_lst = list()
            get_lst = checkHost(ips_get[0], port)
            file.write(
                unicode(ips_get[0] + "\t" +
                        str(get_lst[0]) + "\t" +
                        str(get_lst[1]) + "\t" +
                        str(get_lst[2][0]) + "\t" +
                        str(get_lst[2][1]) + "\t" +
                        str(get_lst[2][2]) + "\t" +
                        str(get_lst[2][3]) + "\t" +
                        str(get_lst[2][4].strip()) + "\n"))

            print "[ ```````````````````````````````````````````` ]\n\n"


printHeader()
data = getFileData()
extractToCSV(data)
