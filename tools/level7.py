def L7(ph1=0.0, ph2=0.5):
    return dict(
        title="LEVEL 7",
        platforms=[(0,400,1100,200),          # P1: speed pad, then faster
                   (1480,400,820,200),        # P2 after a gap only a double jump crosses
                   (2980,300,720,300),        # P3 raised, after the crumbling stairs
                   (4400,400,900,200),        # P4 tower floor
                   (4500,270,400,24),         # A ledge (run right after turning)
                   (4750,140,400,24),         # B ledge with a spike (run left)
                   (4500,10,400,24)],         # C top ledge with the goal (run right)
        crumbles=[(2400,340,120,24),(2600,290,120,24),(2800,240,110,24)],
        movers=[dict(x=3850,top=330,w=140,h=24,dx=0,dy=-140,dur=0.9,phase=ph1),
                dict(x=4100,top=330,w=140,h=24,dx=0,dy=-140,dur=0.9,phase=ph2)],
        pads=[(650,400,380.0)],
        turns=[(5250,400,-1),(4550,270,1),(5100,140,-1),(4550,10,1)],
        spikes=[(450,400),(1750,400),(1790,400),(1830,400),(3250,300),(4700,400),(4740,400),(4950,140)],
        coins=[(450,270),(1290,230),(2855,210),(4170,200),(4950,60),(4700,-20)],
        goal=4800, goal_y=10)
