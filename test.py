#! /usr/bin/python
from TOSSIM import *
import sys

t = Tossim([])
r = t.radio()
f = open("topo.txt", "r")

for line in f:
  s = line.split()
  if s:
    print " ", s[0], " ", s[1], " ", s[2];
    r.add(int(s[0]), int(s[1]), float(s[2]))

t.addChannel("RadioCountToLedsC", sys.stdout)
t.addChannel("Boot", sys.stdout)

noise = open("meyer-heavy.txt", "r")
for line in noise:
  str1 = line.strip()
  if str1:
    val = int(str1)
    for i in range(1, 3):
      t.getNode(i).addNoiseTraceReading(val)


for i in range(1, 3):
  print "Creating noise model for ",i;
  t.getNode(i).createNoiseModel()


t.getNode(1).bootAtTime(100001);
print "node 1 boot schedule"
t.getNode(2).bootAtTime(800008);
print "node 2 boot schedule"
t.getNode(3).bootAtTime(1800009);
print "node 3 boot schedule"

for i in range(100):
	t.runNextEvent()
	print "range: ",i;
