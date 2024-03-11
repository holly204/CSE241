COEN-241 HW3

Task 1: Defining custom topologies

Question 1: What is the output of “nodes” and “net”?

mininet> nodes
available nodes are: 
c0 h1 h2 h3 h4 h5 h6 h7 h8 s1 s2 s3 s4 s5 s6 s7

mininet> net
h1 h1-eth0:s3-eth2
h2 h2-eth0:s3-eth3
h3 h3-eth0:s4-eth2
h4 h4-eth0:s4-eth3
h5 h5-eth0:s6-eth2
h6 h6-eth0:s6-eth3
h7 h7-eth0:s7-eth2
h8 h8-eth0:s7-eth3
s1 lo:  s1-eth1:s2-eth1 s1-eth2:s5-eth1
s2 lo:  s2-eth1:s1-eth1 s2-eth2:s3-eth1 s2-eth3:s4-eth1
s3 lo:  s3-eth1:s2-eth2 s3-eth2:h1-eth0 s3-eth3:h2-eth0
s4 lo:  s4-eth1:s2-eth3 s4-eth2:h3-eth0 s4-eth3:h4-eth0
s5 lo:  s5-eth1:s1-eth2 s5-eth2:s6-eth1 s5-eth3:s7-eth1
s6 lo:  s6-eth1:s5-eth2 s6-eth2:h5-eth0 s6-eth3:h6-eth0
s7 lo:  s7-eth1:s5-eth3 s7-eth2:h7-eth0 s7-eth3:h8-eth0
c0

Question 2: What is the output of "h7 ifconfig"

mininet> h7 ifconfig
h7-eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.0.7  netmask 255.0.0.0  broadcast 10.255.255.255
        inet6 fe80::b4f9:d7ff:fed1:4b04  prefixlen 64  scopeid 0x20<link>
        ether b6:f9:d7:d1:4b:04  txqueuelen 1000  (Ethernet)
        RX packets 60  bytes 4672 (4.6 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 12  bytes 936 (936.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

Task 2: Analyze the "of_tutorial" controller

Question1： Draw the function call graph of this controller. For example, once a packet comes to the
controller, which function is the first to be called, which one is the second, and so forth?

launch() -> start_switch() -> Tutorial.__init__() -> __handle_PacketIn() -> act_like_hub() -> resend_packet() -> self.connection.send(msg)

Question2: Have h1 ping h2, and h1 ping h8 for 100 times (e.g., h1 ping -c100 p2)

a. How long does it take (on average) to ping for each case?
h1 ping h2: 0.248 ms
h1 ping h8: 0.337 ms

b. What is the minimum and maximum ping you have observed?
h1 ping h2:
min: 0.034 max: 11.23 ms
h1 ping h8:
min: 0.047 max: 17.39 ms
 
c. What is the difference, and why?
Since the number of switches for h1 ping h2 is less than h1 ping h8, we observe the time it takes to ping h2 from h1 is much less than it takes to ping h8 from h1.

Question 3: Run “iperf h1 h2” and “iperf h1 h8”

a. What is “iperf” used for?

It is used for TCP bandwidth testing between two hosts

b. What is the throughput for each case?

mininet> iperf h1 h2
*** Iperf: testing TCP bandwidth between h1 and h2 
.*** Results: ['23.74 Mbits/sec', '28.17 Mbits/sec']
mininet> iperf h1 h8
*** Iperf: testing TCP bandwidth between h1 and h8 
*** Results: ['18.46 Mbits/sec', '19.21 Mbits/sec']

c. What is the difference, and explain the reasons for the difference.

I notice the performance of h1 to h2 is better than h1 to h8. And this might relate to the number of switches on the path.

Question 4: Which of the switches observe traffic? Please describe your way for observing such
traffic on switches (e.g., adding some functions in the “of_tutorial” controller).

All the switches observe traffic. To observe traffic on switches, we can add a function to log the packets in the _handle_PacketIn function, before act_like_hub()

Task 3: MAC Learning Controller

Question 1: Describe how the above code works, such as how the "MAC to Port" map is established.
You could use a ‘ping’ example to describe the establishment process (e.g., h1 ping h2).

When "h1 ping h2" is executed, _handle_PacketIn() triggers act_like_switch(), leading to two outcomes depending on the "MAC to Port" map. If the source MAC is unknown, it's added to the map. For packet sending, if the destination MAC is known, the packet is sent directly; if unknown, it follows the act_like_hub() approach.

Question 2: Have h1 ping h2, and h1 ping h8 for 100 times (e.g., h1 ping -c100 p2).

a. How long did it take (on average) to ping for each case?

h1 ping h2: 0.187 ms
h1 ping h8: 0.267 ms

b. What is the minimum and maximum ping you have observed?

h1 ping h2:
min: 0.017 max: 9.87 ms
h1 ping h8:
min: 0.023 max: 13.14 ms

c. Any difference from Task 2 and why do you think there is a change if there is?

I notice the ping time is less compare to task 2. The reason might be the "MAC to Port" map, which reduce the time by sending the packet to the destination directly rather than floor them.

Question 3: Run “iperf h1 h2” and “iperf h1 h8”.

a. What is the throughput for each case?

mininet> iperf h1 h2
*** Iperf: testing TCP bandwidth between h1 and h2 
.*** Results: ['25.69 Mbits/sec', '29.73 Mbits/sec']
mininet> iperf h1 h8
*** Iperf: testing TCP bandwidth between h1 and h8 
*** Results: ['19.74 Mbits/sec', '20.91 Mbits/sec']

b. What is the difference from Task 2 and why do you think there is a change if there is?

There is a slight performance improvement. Again, the reason might be the "MAC to Port" map helps to swtich to route to appropriate destination port.

