from levels import L2, L3
DT=1/60; G=1800; JV=-650; CUT=0.5; COY=0.1
def overlap(a,b): return a[0]<b[2] and a[2]>b[0] and a[1]<b[3] and a[3]>b[1]
def pbox(x,y): return (x-12,y-26,x+12,y+30)

def step(L,R,st,press,release):
    x,y,vy,floor,coy,spd,padmask,coins=st
    for i,(px,s) in enumerate(L["pads"]):
        if not padmask>>i&1 and x+12>px-15 and x-12<px+15: spd=s; padmask|=1<<i
    if floor: coy=COY
    else: coy-=DT; vy+=G*DT
    if press and coy>0: vy=JV; coy=0
    if release and vy<0: vy*=CUT
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
    return (x,y,vy,floor,coy,spd,padmask,coins)

def search(L,want=0,cap=5000):
    R=[(x,t,x+w,t+h) for x,t,w,h in L["platforms"]]
    front=[((100.0,350.0,0.0,False,0.0,300.0,0,0),-1)]   # hold: -1 = not holding
    for f in range(5000):
        nxt={}
        for st,hold in front:
            acts=[(False,hold)]
            if hold<0 and (st[3] or st[4]>0):
                acts+= [(True,k) for k in (1,5,10,1000)]
            for press,h in acts:
                release = (not press and h==0)
                ns=step(L,R,st,press,release)
                if ns is None: continue
                nh = h-1 if h>0 else -1
                if ns[3] and not press: nh=-1        # landed: can press again
                if press: nh=h-1
                key=(round(ns[0]),round(ns[1]),round(ns[2]/30),ns[3],nh>0,ns[6],ns[7])
                if key not in nxt: nxt[key]=(ns,nh)
                if ns[0]>=L["goal"] and (ns[7]&want)==want: return True
        front=list(nxt.values())
        if not front: return False
        if len(front)>cap:
            front.sort(key=lambda s:(-bin(s[0][7]&want).count('1'),-s[0][0])); front=front[:cap]
    return False

if __name__=="__main__":
    for name,L in (("L2",L2),("L3",L3)):
        print(name,"finish:",search(L))
        for i,c in enumerate(L["coins"]): print("  coin",i,c,search(L,1<<i))
        print("  all coins:",search(L,(1<<len(L["coins"]))-1))
