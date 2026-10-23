import sys; sys.setrecursionlimit(100000)
from sim2 import make
from levels import L4
what=sys.argv[1]
fast=dict(holds=(5,1000), air_delays=(None,8,16,24,32), air_holds=(1000,))
if what=="finish": print("finish:", make(L4,**fast)(0))
elif what=="nodouble": print("finish WITHOUT double jump:", make(L4,holds=(5,1000),allow_double=False)(0))
elif what=="all": print("all coins one run:", make(L4,**fast)((1<<6)-1))
elif what.startswith("coin"):
    i=int(what[4:]); print("coin",i,L4["coins"][i], make(L4,**fast)(1<<i))
