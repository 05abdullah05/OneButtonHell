# Simulation with moving + crumbling platforms. Same numbers as the game.
import math, sys
sys.setrecursionlimit(200000)
DT=1/60; G=1800; JV=-650; CUT=0.5; COY=0.1; AIR_JV=-650.0

def overlap(a,b): return a[0]<b[2] and a[2]>b[0] and a[1]<b[3] and a[3]>b[1]
def pbox(x,y): return (x-12,y-26,x+12,y+30)

def mover_pos(m, f):
    # same as moving_platform.gd: k = (1 - cos(t / duration * PI)) / 2
    t = f*DT + m["phase"]*2*m["dur"]
    k = (1-math.cos(t/m["dur"]*math.pi))/2
    return m["x"]+m["dx"]*k, m["top"]+m["dy"]*k

def rects(L, f, crum):
    R=[(x,t,x+w,t+h,None) for x,t,w,h in L["platforms"]]
    for i,m in enumerate(L.get("movers",[])):
        x,t=mover_pos(m,f); R.append((x,t,x+m["w"],t+m["h"],("m",i)))
    for i,c in enumerate(L.get("crumbles",[])):
        x,t,w,h=c
        trig=dict(crum).get(i)
        gone = trig is not None and trig+int(0.5*60) <= f < trig+int(0.5*60)+180
        if not gone: R.append((x,t,x+w,t+h,("c",i)))
    return R

def step(L, st, press, release):
    x,y,vy,floor,coy,coins,air,f,crum,ride = st
    # carried by the platform we stand on
    if ride is not None and ride[0]=="m":
        m=L["movers"][ride[1]]
        x0,y0=mover_pos(m,f); x1,y1=mover_pos(m,f+1)
        x+=x1-x0; y+=y1-y0
    f+=1
    R=rects(L,f,crum)
    if floor: coy=COY; air=1 if L.get("double_jump") else 0
    else: coy-=DT; vy+=G*DT
    if press:
        if coy>0: vy=JV; coy=0
        elif air>0: vy=AIR_JV; air-=1
    if release and vy<0 and not (L.get("double_jump") and air==0): vy*=CUT
    x+=300*DT
    if any(overlap(pbox(x,y),r[:4]) for r in R): return None
    y+=vy*DT; floor=False; ride=None
    for r in R:
        if overlap(pbox(x,y),r[:4]):
            if vy>=0: y=r[1]-30; vy=0; floor=True; ride=r[4]
            else: y=r[3]+26; vy=0
    if not floor:
        b=pbox(x,y)
        for r in R:
            if b[0]<r[2] and b[2]>r[0] and abs(b[3]-r[1])<1.0: floor=True; ride=r[4]; y=r[1]-30
    # crumble trigger: standing on it
    if floor and ride is not None and ride[0]=="c" and ride[1] not in dict(crum):
        crum=tuple(sorted(dict(crum).items())+[(ride[1],f)]); crum=tuple(sorted(crum))
    if any(overlap(pbox(x,y),(sx-12,sy-20,sx+12,sy)) for sx,sy in L["spikes"]): return None
    if y>1000: return None
    b=pbox(x,y)
    for i,(cx,cy) in enumerate(L["coins"]):
        qx=min(max(cx,b[0]),b[2]); qy=min(max(cy,b[1]),b[3])
        if (qx-cx)**2+(qy-cy)**2<18*18: coins|=1<<i
    return (x,y,vy,floor,coy,coins,air,f,crum,ride)

def make(L, holds=(6,1000), air_delays=(None,8,16,24,32), allow_double=True):
    gx=L["goal"]
    def fly(st,hold,air_at):
        k=0; h=hold if hold is not None else -1
        while True:
            press=(k==0 and hold is not None) or (air_at is not None and k==air_at)
            rel=False
            if k>0 and h>0:
                h-=1
                if h==0: rel=True
            ns=step(L,st,press,rel)
            if ns is None: return None
            st=ns; k+=1
            if st[0]>=gx: return ("GOAL",st[5])
            if st[3] and (k>1 or hold is None): return st
            if k>500: return None
    seen={}
    def best(st,want):
        key=(round(st[0]),round(st[1]),st[7],st[8],st[5]&want)
        if key in seen: return seen[key]
        seen[key]=False; res=False
        for hd in holds:
            for ad in (air_delays if allow_double else (None,)):
                r=fly(st,hd,ad)
                if r is None: continue
                if r[0]=="GOAL":
                    if r[1]&want==want: res=True; break
                    continue
                if best(r,want): res=True; break
            if res: break
        if not res:
            r=fly(st,None,None)
            if r is not None:
                res=((r[1]&want)==want) if r[0]=="GOAL" else best(r,want)
        seen[key]=res; return res
    def solve(want=0):
        seen.clear()
        st=(100.0,350.0,0.0,False,0.0,0,0,0,(),None)
        st=fly(st,None,None)
        return best(st,want)
    return solve

def furthest(L):
    # how far can we get at all (for debugging a layout)
    best=[0]
    def fly_all(st,depth=0):
        pass
    import collections
    front=[(100.0,350.0,0.0,False,0.0,0,0,0,(),None)]
    seen=set()
    while front:
        st=front.pop()
        key=(round(st[0]),round(st[1]),st[7]//2,st[8])
        if key in seen: continue
        seen.add(key); best[0]=max(best[0],st[0])
        for hd in (None,6,1000):
            for ad in ((None,) if hd is None else (None,10,20,30)):
                s=st; k=0; h=hd if hd else -1
                while True:
                    press=(k==0 and hd is not None) or (ad is not None and k==ad)
                    rel=False
                    if k>0 and h>0:
                        h-=1
                        if h==0: rel=True
                    s=step(L,s,press,rel)
                    if s is None: break
                    best[0]=max(best[0],s[0]); k+=1
                    if s[3] and (k>1 or hd is None): front.append(s); break
                    if k>500: break
    return best[0]
