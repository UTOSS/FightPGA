# COORDINATES ARE (0,0) in the top left

import pygame
import random

pygame.init()
#pygame.key.set_repeat(1000/FPS)

pygame.font.init() # you have to call this at the start,
                   # if you want to use this module.
my_font = pygame.font.SysFont('Comic Sans MS', 30)

# Basic parameters of the screen
WIDTH, HEIGHT = 900, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Myhal Rapids")

# Used to adjust the frame rate
clock = pygame.time.Clock()
FPS = 60
WHITE = (255, 255, 255)
BLACK = (0,0,0)
RED = (255, 0, 0)
BLUE = (0, 0, 255)
STATES = ["NOTHING", "WALKFORWARD", "WALKBACKWARD", "KICK", "GRAB", "BLOCK", "KICKED", "GRABBED", "WIN", "LOSE"]
ACTIONABLE = ["NOTHING", "WALKFORWARD", "WALKBACKWARD", "BLOCK"]
FSPEED = 5
BSPEED = 4
RADIUS = 40
PWIDTH = 150
PHEIGHT = 400
FLOOR_HEIGHT = 55
P1START = 50
P2START = WIDTH-P1START-PWIDTH
P1KEYS={"wb": pygame.K_a, "wf": pygame.K_d, "k": pygame.K_q, "b": pygame.K_w, "g": pygame.K_e}
P2KEYS={"wf": pygame.K_j, "wb": pygame.K_l, "k": pygame.K_u, "b": pygame.K_i, "g": pygame.K_o}
KICK_STARTUP = 15
KICK_ENDLAG = 20
GRAB_STARTUP = 5
GRAB_ENDLAG=30
KICK_RANGE=44
GRAB_RANGE=int(KICK_RANGE/4)
GRAB_ACTIVE=GRAB_ENDLAG
KICK_ACTIVE=KICK_ENDLAG
#       LEFT        RIGHT       KICK        BLOCK       GRAB

class Player:
    def __init__(self, position, state, player):
        self.position = position
        self.state = state
        self.player = player #PLAYER NUMBER: 0 FOR P1, 1 FOR P2
        self.sprite=pygame.draw.rect(screen, self.getcolor(), pygame.Rect(self.position, HEIGHT-FLOOR_HEIGHT-PHEIGHT, PWIDTH, PHEIGHT))
        self.action_timer=0
    def getcolor(self):
        if self.player==1:
            return RED
        else:
            return BLUE
    def get_direction_mult(self):
        if self.player==1:
            return 1
        else:
            return -1
    def collision_check(self,op):
        if self.player == 1:
            p1 = self
            p2 = op
        else:
            p1 = op
            p2 = self
        return p1.position >= p2.position-PWIDTH
    def range_check(self, op, attack_range):
        if self.player == 1:
            return len(set(range(self.position+PWIDTH,self.position+PWIDTH+attack_range+1)) & set(range(op.position,op.position+PWIDTH)) )>0
        else:
            return len(set(range(self.position-attack_range-1, self.position))&set(range(op.position,op.position+PWIDTH)))>0
        return p1.position >= p2.position-PWIDTH
    def send_key(self, action):
        if self.state in ACTIONABLE or self.action_timer<=0:
            self.state=action
            if self.state == "KICK":
                self.action_timer = KICK_STARTUP + KICK_ENDLAG
            elif self.state == "GRAB":
                self.action_timer = GRAB_STARTUP + GRAB_ENDLAG
    def update_by_state(self, op):
        if self.state=="LOSE" or self.state=="WIN":
            return
        if self.state=="WALKFORWARD":
            self.action_timer=-1
            self.position = min(max(self.position + FSPEED*self.get_direction_mult(),0),WIDTH-PWIDTH)
            if self.collision_check(op):
                self.position=op.position-self.get_direction_mult()*PWIDTH
        elif self.state=="WALKBACKWARD":
            self.action_timer=-1
            self.position = min(max(self.position - BSPEED*self.get_direction_mult(),0),WIDTH-PWIDTH)
        elif self.action_timer == "BLOCK":
            self.action_timer=-1
        elif self.state =="KICK":
            self.action_timer=max(self.action_timer-1, 0)
            if self.action_timer==KICK_ACTIVE and not op.state=="BLOCK" and self.range_check(op, KICK_RANGE):
                self.state="WIN"
                op.state="LOSE"
        elif self.state =="GRAB":
            self.action_timer=max(self.action_timer-1, 0)
            if self.action_timer==GRAB_ACTIVE and self.range_check(op, GRAB_RANGE):
                self.state="WIN"
                op.state="LOSE"
    def display(self):
        if self.state in ACTIONABLE:
            self.sprite=pygame.draw.rect(screen, self.getcolor(), pygame.Rect(self.position, HEIGHT-FLOOR_HEIGHT-PHEIGHT, PWIDTH, PHEIGHT))
        #self.action_timer = max(self.action_timer-1, 0)
    def get_hitbox(self):
        return (self.position, self.position+PWIDTH)

def main():
    running = True
    p1=Player(P1START, "NOTHING", 1)
    p2=Player(P2START, "NOTHING", 2)
    floor = pygame.Rect(0, HEIGHT-FLOOR_HEIGHT, WIDTH, FLOOR_HEIGHT)
    while running:
        screen.fill(WHITE)
        pygame.draw.rect(screen, BLACK, floor)
        p1.update_by_state(p2)
        p2.update_by_state(p1)
        p1.display()
        p2.display()
        p1_state_surface = my_font.render(p1.state+str(p1.range_check(p2, KICK_RANGE)), False, p1.getcolor())
        p2_state_surface = my_font.render(p2.state+str(p2.range_check(p1, KICK_RANGE)), False, p2.getcolor())
        screen.blit(p1_state_surface, (0,0))
        screen.blit(p2_state_surface, (0,30))
        keys=pygame.key.get_pressed()
        ##P1 logic

        if keys[P1KEYS["b"]]:
            p1_next_state="BLOCK"
        elif keys[P1KEYS["k"]]:
            p1_next_state="KICK"
        elif keys[P1KEYS["g"]]:
            p1_next_state="GRAB"
        elif keys[P1KEYS["wb"]]:
            p1_next_state="WALKBACKWARD"
        elif keys[P1KEYS["wf"]]:
            p1_next_state="WALKFORWARD"
        else:
            p1_next_state="NOTHING"
        ##P2 LOGIC

        if keys[P2KEYS["b"]]:
            p2_next_state="BLOCK"
        elif keys[P2KEYS["k"]]:
            p2_next_state="KICK"
        elif keys[P2KEYS["g"]]:
            p2_next_state="GRAB"
        elif keys[P2KEYS["wb"]]:
            p2_next_state="WALKBACKWARD"
        elif keys[P2KEYS["wf"]]:
            p2_next_state="WALKFORWARD"
        else:
            p2_next_state="NOTHING"

        p1.send_key(p1_next_state)
        p2.send_key(p2_next_state)
        # Event handling
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            '''if p1.state in ACTIONABLE:
                if event.key == P1KEYS['b']:
                    p1.state="BLOCK"'''

        pygame.display.update()
        clock.tick(FPS)

        if p1.state=="WIN" or p2.state=="WIN":
            if p1.state=="WIN":
                wcol=RED
            else:
                wcol=BLUE
            screen.fill(wcol)
            pygame.display.update()
            for i in range(int(FPS/2)):
                clock.tick(FPS)
            running=False
    if running==False and (p1.state=="WIN" or p2.state=="WIN"):
        main()

if __name__ == "__main__":
    main()
    pygame.quit()