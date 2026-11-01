# Simulation with moving + crumbling platforms AND turn arrows (direction changes).
import math, sys
sys.setrecursionlimit(200000)
DT=1/60; G=1800; JV=-650; CUT=0.5; COY=0.1; AIR_JV=-650.0; TURN_H=160

def overlap(a,b): return a[0]<b[2] and a[2]>b[0] and a[1]<b[3] and a[3]>b[1]
def pbox(x,y): return (x-12,y-26,x+12,y+30)

def mover_pos(m,f):
    t=f*DT+m["phase"]*2*m["dur"]; k=(1-math.cos(t/m["dur"]*math.pi))/2
    return m["x"]+m["dx"]*k, m["top"]+m["dy"]*k

def rects(L,f,crum):
    R=[(x,t,x+w,t+h,None) for x,t,w,h in L["platforms"]]
    for i,m in enumerate(L.get("movers",[])):
        x,t=mover_pos(m,f); R.append((x,t,x+m["w"],t+m["h"],("m",i)))
    cd=dict(crum)
    for i,(x,t,w,h) in enumerate(L.get("crumbles",[])):
        trig=cd.get(i)
        gone=trig is not None and trig+30<=f<trig+30+180
        if not gone: R.append((x,t,x+w,t+h,("c",i)))
    return R

# state: x,y,vy,floor,coy,coins,air,f,crum,ride,dir,speed
def step(L,st,press,release):
    x,y,vy,floor,coy,coins,air,f,crum,ride,d,spd=st
    if ride is not None and ride[0]=="m":
        m=L["movers"][ride[1]]; x0,y0=mover_pos(m,f); x1,y1=mover_pos(m,f+1); x+=x1-x0; y+=y1-y0
    f+=1; R=rects(L,f,crum)
    if floor: coy=COY; air=1
    else: coy-=DT; vy+=G*DT
    if press:
        if coy>0: vy=JV; coy=0
        elif air>0: vy=AIR_JV; air-=1
    if release and vy<0 and not air==0: vy*=CUT
    x+=spd*DT*d
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
    if floor and ride is not None and ride[0]=="c" and ride[1] not in dict(crum):
        crum=tuple(sorted(list(crum)+[(ride[1],f)]))
    b=pbox(x,y)
    for (tx,ty,nd) in L.get("turns",[]):
        if overlap(b,(tx-15,ty-TURN_H,tx+15,ty)): d=nd
    for (px,py,ns) in L.get("pads",[]):
        if overlap(b,(px-15,py-240,px+15,py)): spd=ns
    if any(overlap(b,(sx-12,sy-20,sx+12,sy)) for sx,sy in L["spikes"]): return None
    if y>1000: return None
    for i,(cx,cy) in enumerate(L["coins"]):
        qx=min(max(cx,b[0]),b[2]); qy=min(max(cy,b[1]),b[3])
        if (qx-cx)**2+(qy-cy)**2<18*18: coins|=1<<i
    return (x,y,vy,floor,coy,coins,air,f,crum,ride,d,spd)

def reach(L, start, done, want=0, holds=(6,1000), air_delays=(None,8,16,24,32), limit=400000, track=False):
    """DFS from a standing state until done(state) is True with the wanted coins."""
    seen=set(); stack=[(start,0.0)]; n=0
    while stack:
        s,dist=stack.pop(); n+=1
        if n>limit: return None
        key=(round(s[0]),round(s[1]),s[8],s[5],s[10],s[11])
        if key in seen: continue
        seen.add(key)
        for hd,ad in [(None,None)]+[(h,a) for h in holds for a in air_delays]:
            q=s; k=0; h=hd if hd is not None else -1; dd=dist
            while True:
                press=(k==0 and hd is not None) or (ad is not None and k==ad)
                rel=False
                if k>0 and h>0:
                    h-=1
                    if h==0: rel=True
                nq=step(L,q,press,rel)
                if nq is None: break
                dd+=abs(nq[0]-q[0]); q=nq; k+=1
                if done(q):
                    if (q[5]&want)==want: return (True,dd) if track else True
                    break
                if q[3] and (k>1 or hd is None): stack.append((q,dd)); break
                if k>500: break
    return False

def standing(L,x,top,d=1,spd=300.0,f=None):
    if f is None: f=int(round(abs(x-100)/5))
    return (float(x),top-30.0,0.0,True,0.1,0,1,f,(),None,d,spd)
