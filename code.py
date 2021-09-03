#!/usr/bin/env python

from ping import Ping, PingStats

host = 'fc00:0011:0050:2947:0000:0000:0000:0001'
p = Ping(host, timeout=3000, quiet=False, silent=False, ipv6=True)
try:
    stats = p.run(4)  # PingStats
    print(PingStats.packets_sent)
    print(PingStats.packets_received)
    print("AVG: ", stats.average_time)
    print("MAX: ", stats.max_time)
    print("MIN: ", stats.min_time)
except:
    print("AVG: ", 0)
    print("MAX: ", 0)
    print("MIN: ", 0)

# class PingStats:
#     destination_ip
#     destination_host
#     destination_port
#     packets_sent
#     packets_received
#     lost_rate
#     min_time
#     max_time
#     total_time
#     average_time
