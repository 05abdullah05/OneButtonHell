def L5(ph=(0.0,0.5,0.0,0.0)):
    return dict(
        title="LEVEL 5", double_jump=True,
        platforms=[(0,400,1000,200),        # P1 start + safe crumble intro above
                   (1600,400,700,200),      # P2 after the bobbing steps
                   (2560,150,600,450),      # P3 high ledge (250 up: needs the elevator)
                   (3900,400,900,200),      # P4 after the crumble bridge
                   (5300,400,700,200)],     # P5 goal
        crumbles=[(420,310,140,24),(620,310,140,24),
                  (3260,260,130,24),(3460,260,130,24),(3660,260,130,24)],
        movers=[dict(x=1150,top=380,w=140,h=24,dx=0,dy=-120,dur=1.2,phase=ph[0]),  # M1 bobbing step
                dict(x=1380,top=380,w=140,h=24,dx=0,dy=-120,dur=1.2,phase=ph[1]),  # M2 bobbing step
                dict(x=2330,top=400,w=160,h=24,dx=0,dy=-200,dur=1.5,phase=ph[2]),  # M3 elevator
                dict(x=4950,top=380,w=160,h=24,dx=0,dy=-130,dur=1.0,phase=ph[3])], # M4 final bobber
        spikes=[(1900,400),(2850,150),(4150,400),(4190,400)],
        coins=[(490,280),(690,280),(1450,200),(2850,80),(3525,200),(5030,220)],
        pads=[], goal=5800)
