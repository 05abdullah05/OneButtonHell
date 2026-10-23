import sys, math
from sim3 import step
def section_ok(L, x0, top, x_end, holds=(6,1000), air_delays=(None,8,16,24,32), want_coins=0, allow_double=True):
    """Can the player get from standing at x0 (on a surface at 'top') to x_end?"""
    f0=int(round((x0-100)/5))
    st=(float(x0), top-30.0, 0.0, True, 0.1, 0, 1, f0, (), None)
    seen=set(); stack=[st]
    while stack:
        s=stack.pop()
        if s[0]>=x_end and (s[5]&want_coins)==want_coins: return True
        key=(round(s[0]),round(s[1]),s[8],s[5])
        if key in seen: continue
        seen.add(key)
        opts=[(None,None)]+[(h,a) for h in holds for a in (air_delays if allow_double else (None,))]
        for hd,ad in opts:
            q=s; k=0; h=hd if hd is not None else -1
            while True:
                press=(k==0 and hd is not None) or (ad is not None and k==ad)
                rel=False
                if k>0 and h>0:
                    h-=1
                    if h==0: rel=True
                q=step(L,q,press,rel)
                if q is None: break
                k+=1
                if q[0]>=x_end:
                    if (q[5]&want_coins)==want_coins: return True
                    break
                if q[3] and (k>1 or hd is None): stack.append(q); break
                if k>500: break
    return False
