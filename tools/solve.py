import sys
from functools import lru_cache
from sim import step
from levels import L2, L3
sys.setrecursionlimit(100000)
HOLDS=(1,4,8,14,1000)

def make(L):
    R=[(x,t,x+w,t+h) for x,t,w,h in L["platforms"]]
    def fly(st,press,hold):
        # simulate from st with optional press; return landed state or goal/None
        first=True; h=hold
        while True:
            rel = (not first) and h==0
            ns=step(L,R,st,press and first,rel)
            if first and press: h=hold-1
            elif h>0: h-=1
            else: h=-1
            first=False
            if ns is None: return None
            st=ns
            if st[0]>=L["goal"]: return ("GOAL",st[7])
            if st[3] and (not press or h!=hold-1): return st
    seen={}
    def best(st, want):
        # returns True if goal reachable collecting 'want' from floor state st
        key=(round(st[0]),round(st[1]),st[5],st[6],st[7]&want)
        if key in seen: return seen[key]
        seen[key]=False
        res=False
        # option: jump now
        for hd in HOLDS:
            r=fly(st,True,hd)
            if r is None: continue
            if r[0]=="GOAL":
                if r[1]&want==want: res=True; break
                continue
            if best(r,want): res=True; break
        if not res:
            r=fly(st,False,0)   # wait: walks 1+ frames (until "landed" again = next frame on floor)
            if r is not None:
                if r[0]=="GOAL": res = (r[1]&want)==want
                else: res=best(r,want)
        seen[key]=res
        return res
    def solve(want=0):
        seen.clear()
        st=(100.0,350.0,0.0,False,0.0,300.0,0,0)
        st=fly(st,False,0)  # drop to floor
        return best(st,want)
    return solve

for name,L in (("L2",L2),("L3",L3)):
    s=make(L)
    print(name,"finish:",s(0))
    for i,c in enumerate(L["coins"]): print("  coin",i,c,s(1<<i))
    print("  all coins:",s((1<<len(L["coins"]))-1))
