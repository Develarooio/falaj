* Players have health bars 
    - which can be depleted by being punched by other characters
    - which refill to 100% after a period of not being punched (and while not holding the ball)
* Players have punches which:
    - can be charged at a speed which varies with the character
    - have a knock back effect which varies based on the character and scales
      in strength with the level of charge at which the punch was released
* Players can jump, which:
    - varies in height based on character
* Players can run, which:
    - varies in speed based on the character
* There is a ball which:
    - when carried by a character to their goal, wins the game for that chareacter
    - when being carried, prevents the character from punching
* Players can reach a zero-health state which:
    - stuns them momentarily
    - if they are carrying the ball, causes them to drop the ball
* Players start out in a random pure state
* There are mutators which:
    - Can be consumed by colliding with them
    - Respawn after x time after consumption
    - Spawn in predetermined locations in each map


A player's composition transitions as follows where one step in the flow is made by touching a mutator:

100/0/0 -> 50/50/0 -> 33/33/33 -> 25/25/50 -> 50/0/50 -> 0/0/100
                                           -> 0/0/100

Mutators are placed randomly around the map

* Bear:
    - Punch: 20
    - Speed: 5
    - Jump: 3

* Snake:
    - Punch: 2
    - Speed: 20
    - Jump: 4

* Bird:
    - Punch: 5
    - Speed: 12
    - Jump: 20


