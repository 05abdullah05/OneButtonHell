import sim2
from sim2 import step
def window(ledge_up, gap, strength, tap_frames, cut_on_air):
    sim2.AIR_JV=-650*strength
    top=400-ledge_up
    L=dict(platforms=[(0,400,2300,200),(2300+gap,top,600,400)],spikes=[],coins=[],pads=[],double_jump=True)
    R=[(x,t,x+w,t+h) for x,t,w,h in L["platforms"]]
    ok=0
    for jx in range(1900,2310,5):
        for ad in range(2,50):
            st=(jx-5.0,370.0,0.0,True,0.1,300.0,0,0,1); f=0; alive=True
            while f<200:
                press=(f==0) or (f==ad)
                rel=(f==tap_frames) or (cut_on_air and f==ad+tap_frames)
                ns=step(L,R,st,press,rel)
                if ns is None: alive=False; break
                st=ns; f+=1
                if st[3] and f>2: break
            if alive and st[1]<370-ledge_up+1: ok+=1
    return ok
print("Quick double-tap (each press held ~0.1 s):")
for up,gap,s,cut in [(160,120,0.9,True),(160,120,0.9,False),(140,0,1.0,True),(140,0,1.0,False)]:
    print(f"  ledge {up}, gap {gap}, strength {s}, air jump {'CAN' if cut else 'can NOT'} be cut short: {window(up,gap,s,6,cut)} working combos")
