# Physics simulation with double jump. Same numbers as player.gd.
from levels import L2, L3, L4
DT=1/60; G=1800; JV=-650; CUT=0.5; COY=0.1; AIR_JV=-650*1.0
def overlap(a,b): return a[0]<b[2] and a[2]>b[0] and a[1]<b[3] and a[3]>b[1]
def pbox(x,y): return (x-12,y-26,x+12,y+30)

def step(L,R,st,press,release):
    x,y,vy,floor,coy,spd,padmask,coins,air=st
    for i,(px,s) in enumerate(L["pads"]):
        if not padmask>>i&1 and x+12>px-15 and x-12<px+15: spd=s; padmask|=1<<i
    if floor: coy=COY; air=1 if L.get("double_jump") else 0
    else: coy-=DT; vy+=G*DT
    if press:
        if coy>0: vy=JV; coy=0
        elif air>0: vy=AIR_JV; air-=1
    if release and vy<0 and not (L.get('double_jump') and air==0): vy*=CUT   # air jump can't be cut
    x+=spd*DT
    if any(overlap(pbox(x,y),r) for r in R): return None
    y+=vy*DT; floor=False
    for r in R:
        if overlap(pbox(x,y),r):
            if vy>0: y=r[1]-30; vy=0; floor=True
            else: y=r[3]+26; vy=0
    if not floor:
        b=pbox(x,y)
        for r in R:
            if b[0]<r[2] and b[2]>r[0] and abs(b[3]-r[1])<0.5: floor=True
    if any(overlap(pbox(x,y),(sx-12,sy-20,sx+12,sy)) for sx,sy in L["spikes"]): return None
    if y>1000: return None
    b=pbox(x,y)
    for i,(cx,cy) in enumerate(L["coins"]):
        qx=min(max(cx,b[0]),b[2]); qy=min(max(cy,b[1]),b[3])
        if (qx-cx)**2+(qy-cy)**2<18*18: coins|=1<<i
    return (x,y,vy,floor,coy,spd,padmask,coins,air)

def make(L, holds=(1,5,10,1000), air_delays=(None,4,8,12,16,20,24,30,36), air_holds=(5,1000), allow_double=True):
    R=[(x,t,x+w,t+h) for x,t,w,h in L["platforms"]]
    gx=L["goal"]
    def fly(st,hold,air_at,air_hold):
        f=0; h1=hold if hold is not None else -1; h2=-1
        while True:
            press = (f==0 and hold is not None) or (air_at is not None and f==air_at)
            rel=False
            if f>0:
                if h1>0: h1-=1
                if h1==0: rel=True; h1=-1
                if h2>0: h2-=1
                if h2==0: rel=True; h2=-1
            if air_at is not None and f==air_at: h2=air_hold
            ns=step(L,R,st,press,rel)
            if ns is None: return None
            st=ns; f+=1
            if st[0]>=gx: return ("GOAL",st[7])
            if st[3] and f>1: return st
            if hold is None and st[3]: return st
            if f>400: return None
    seen={}
    def best(st,want):
        key=(round(st[0]),round(st[1]),st[5],st[6],st[7]&want)
        if key in seen: return seen[key]
        seen[key]=False; res=False
        for hd in holds:
            for ad in (air_delays if allow_double else (None,)):
                for ah in (air_holds if ad is not None else (0,)):
                    r=fly(st,hd,ad,ah)
                    if r is None: continue
                    if r[0]=="GOAL":
                        if r[1]&want==want: res=True; break
                        continue
                    if best(r,want): res=True; break
                if res: break
            if res: break
        if not res:
            r=fly(st,None,None,0)
            if r is not None:
                res = ((r[1]&want)==want) if r[0]=="GOAL" else best(r,want)
        seen[key]=res; return res
    def solve(want=0):
        seen.clear()
        st=fly((100.0,350.0,0.0,False,0.0,300.0,0,0,0),None,None,0)
        return best(st,want)
    return solve

if __name__=="__main__":
    import sys; sys.setrecursionlimit(100000)
    L=L4
    s=make(L); print("L4 finish:",s(0))
    for i,c in enumerate(L["coins"]): print("  coin",i,c,s(1<<i))
    print("  all coins one run:",s((1<<len(L["coins"]))-1))
    s=make(L,allow_double=False); print("L4 finish WITHOUT double jump:",s(0))
    s=make(L,holds=(1000,),air_holds=(1000,)); print("L4 finish with full presses only:",s(0))
