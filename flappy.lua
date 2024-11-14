-- title:  Flappy TIC
-- author: TheWatermelon
-- desc:   short description
-- script: lua

--//===========//
--// GAMESTATE //
--//===========//
--// 0 : main menu
--// 1 : game
--// 2 : pause
--// 3 : game over 
MENU_MAIN=0
GAME=1
MENU_PAUSE=2
MENU_GAME_OVER=3
GAMESTATE=MENU_MAIN

t=0 -- time since start of game
x=56 -- TIC pos x
y=24 -- TIC pos y
-- gravity is a negative value
jump_gravity=-0.05
-- speed is initial velocity
-- relative velocity is velocity(x) = speed + gravity * x
-- relative position is position(x) = 0.5 * gravity * x^2 + speed * x
jump_speed=1.2
-- timer acts as x value in f(x) = gravity * x^2 + speed * x 
jump_timer=0
jump_velocity=0
score_zone=0 -- store pipe index when crossing
score=0 -- increments when crossing pipes

-- an array containing 4 pipes with coodinates
pipes = {}

--// modulo(a,b)
-- returns a % b
function modulo(a,b)
	return a-math.floor(a/b)*b
end

--// generate_pipe(index)
-- get random coordinates for a pipe
-- and store them in pipes[index]
function generate_pipe(index)
	-- increasing difficulty
	difficulty=math.floor(score/10)
	-- pipe[1] -> pipe_x
	if index==1 then
		if pipes[index][1]<240 then
			pipes[index][1] = pipes[4][1]+pipes[4][4]
		end
	else
		pipes[index][1] = pipes[index-1][1]+pipes[index-1][4]
	end
	-- pipe[2] -> pipe_top_y
	pipes[index][2]=math.random(1,80)
	-- pipe[3] -> pipe_space
	pipes[index][3]=math.random(36-difficulty,50)
	-- pipe[4] -> inter pipe space
	pipes[index][4]=math.random(70-difficulty,100)
end

--// initialize_pipes()
-- generate all 4 pipes
function initialize_pipes()
	for i=1,4 do
		pipes[i] = {240,0,0,90}
		generate_pipe(i)
	end
end

--// move_pipes()
-- decrement each pipe x coordinate to make
-- them closer to TIC
-- if a pipe gets out of screen, generate a new one
function move_pipes()
	for i=1,4 do
		pipes[i][1]=pipes[i][1]-1
		if pipes[i][1]<-16 then generate_pipe(i) end
	end
end

--// get_jump_velocity
-- returns velocity based on gravity, jump_speed and jump_timer
function get_jump_velocity()
	-- the velocity is positive until max height then negative
	jump_velocity=jump_speed+jump_gravity*jump_timer
	return jump_velocity
end

--// move_tic()
-- change TIC pos y based on velocity
function move_tic()
	-- positive velocity -> bird move up
	-- negative velocity -> bird move down
	y=y-get_jump_velocity()
end

--// check_score()
-- increments score when TIC crosses a pipe
-- store the current pipe index in score_zone
function check_score()
 tic_x1=x+8
 
 current_pipe=0
 for i=1,4 do
 	box_x1=pipes[i][1]+1
		box_x2=box_x1+14
		
		if tic_x1>=box_x1 and tic_x1<=box_x2 then
		 current_pipe=i
			break
		end
 end
 if current_pipe==0 and score_zone>0 then
 	score=score+1
  score_zone=0
 elseif current_pipe>0 then
  score_zone=current_pipe
 end
end

--// check_collision()
-- returns true if TIC touches a pipe
function check_collision()
	-- tic collision box is a 2x2 box in the middle of the sprite
	tic_x1=x+6
	tic_x2=tic_x1+4
	tic_y1=y+6
	tic_y2=tic_y1+4

	for i=1,4 do
		-- box represents inner space between pipes
		box_x1=pipes[i][1]+1
		box_x2=box_x1+14
		box_y1=pipes[i][2]+6
		box_y2=pipes[i][2]+pipes[i][3]+1
		
		if ((tic_x1>=box_x1 and tic_x1<=box_x2) or (tic_x2>=box_x1 and tic_x2<=box_x2)) and (tic_y1<=box_y1 or tic_y2>=box_y2) then
			return true
		end
	end
	return false
end

--// start_jump()
-- set up the timer for a new jump
function start_jump()
	if jump_timer<30 then
		jump_speed=jump_speed*1.05
	else
		jump_speed=1.2
	end
	jump_timer=0
end

--// get_tic_sprite()
-- return tic sprite ID based on velocity
function get_tic_sprite()
	threshold=0.35
	if jump_velocity<-threshold then return 33
	elseif jump_velocity<threshold then return 1
	else return 3 end
end

--// new_game()
-- set up base parameters for new game
-- get new pipes coordinates
function new_game()
 GAMESTATE=GAME
 y=24
 jump_timer=0
 jump_speed=1.2
 jump_velocity=0
 score=0
 score_zone=0
	initialize_pipes()
end

-- LOOP
function TIC()
	if GAMESTATE==MENU_MAIN then
		cls(0)
		print("FLAPPY TIC",80,50,12,true,1,false)
		print("PRESS  TO PLAY",74,67,12,true,1,false)
		spr(9,106,65,0,1,0,0,1,1)
		-- INPUT
		if btnp(4) then new_game() end
	elseif GAMESTATE==MENU_PAUSE then
	 rect(52,40,136,35,0)
		rectb(51,39,138,37,12)
		print("(PAUSE)",100,50,12,true,1,false)
		print("PRESS  TO CONTINUE",67,60,12,true,1,false)
		spr(9,99,59,0,1,0,0,1,1)
		-- INPUT
		if btnp(4) then GAMESTATE=GAME end 
	elseif GAMESTATE==MENU_GAME_OVER then
		rect(50,40,138,35,0)
		rectb(49,39,140,37,12)
		print("GAME OVER",90,50,12,true,1,false)
		print("PRESS  TO MAIN MENU",60,60,12,true,1,false)
		spr(10,92,59,0,1,0,0,1,1)
		-- INPUT
		if btnp(5) then GAMESTATE=MENU_MAIN end
	elseif GAMESTATE==GAME then
		-- btn(0) : UP ARROW
		-- btn(1) : DOWN ARROW
		-- btn(2) : LEFT ARROW
		-- btn(3) : RIGHT ARROW
		-- btn(4) : Z (A ON CONTROLLER)
		if btnp(4) then start_jump() end
		-- btn(5) : X (B ON CONTROLLER)
		if btnp(5) then GAMESTATE=MENU_PAUSE end
		-- btn(6) : A (X ON CONTROLLER)
		-- btn(7) : S (Y ON CONTROLLER)

		-- GAME BACKGROUND
		cls(14)
		-- TIC sprite
		spr(get_tic_sprite(),x,y,14,1,0,0,2,2)
		-- pipes
		for p=1,4 do
			for i=pipes[p][2]-8,-8,-8 do
				spr(7,pipes[p][1],i,14,1,0,0,2,1)
			end
			spr(5,pipes[p][1],pipes[p][2],14,1,0,0,2,1)
			spr(21,pipes[p][1],pipes[p][2]+pipes[p][3],14,1,0,0,2,1)
			for i=pipes[p][2]+pipes[p][3]+8,136,8 do
				spr(23,pipes[p][1],i,14,1,0,0,2,1)
			end

			-- HIT BOXES
			--pix(pipes[p][1]+1,pipes[p][2]+6,2)
			--pix(pipes[p][1]+14,pipes[p][2]+6,2)
			--pix(pipes[p][1]+1,pipes[p][2]+pipes[p][3]+1,2)
			--pix(pipes[p][1]+14,pipes[p][2]+pipes[p][3]+1,2)
		end
		-- TIC HIT BOX
		--rect(x+6,y+6,4,4,6)
		
		-- INFO
		print(score,9,9,0,true,2,false)
		print(score,8,8,12,true,2,false)
		-- A BUTTON
		spr(9,190,7,0,1,0,0,1,1)
		print("JUMP",200,8,12,true,1,false)
		-- B BUTTON
		spr(10,190,15,0,1,0,0,1,1)
		print("PAUSE",200,16,12,true,1,false)

		-- DEBUG
		--print(get_jump_velocity(),8,16,12,true,1,false)
		move_tic()
		move_pipes()
		check_score()
		-- if TIC touches pipe -> GAME OVER
		if check_collision() then GAMESTATE=MENU_GAME_OVER end
		-- TIC continues falling
		jump_timer=jump_timer+1
	end
	-- GAME TIME
	t=t+1
end

-- <TILES>
-- 001:eeeeeeeeeeeeeeeeeeffffffee000000ee000000ee000000ee000004ee000044
-- 002:eeeeeeeeeeeeeeeeffffeeee0000feee00000fee00000fee400000ee440000ee
-- 003:eeeeeeeeeeeeeeffeeeeef00eeeef000eeef0000eef00000ef000004f0000044
-- 004:eeeeeeeeffeeeeee000eeeee0000eeee00004eee000444ee0044430e40033000
-- 005:effff000ef0f0f00eff0f000ef0fffffefff2dd9eef22dd9eee2ff49eee4eeee
-- 006:00000ffe000000fe00000ffeffff00fed6d3fffed6d33feef6ff4eeee4eeeeee
-- 007:eff0f000ef0fff00eff0f000efff0f00eff0f000ef0fff00eff0f000efff0f00
-- 008:00000ffe000000fe00000ffe000000fe00000ffe000000fe00000ffe000000fe
-- 009:0555555055566555556556555566665555655655556556556555555606666660
-- 010:0222222022111222221221222211122222122122221112221222222101111110
-- 011:0aaaaaa0aa9aa9aaaa9aa9aaaaa99aaaaa9aa9aaaa9aa9aa9aaaaaa909999990
-- 012:0444444044344344443443444443334444444344443334443444444303333330
-- 017:ee000034ee000003ee000000ee0e0000ee0ee000ee000000eeeeeeeeeeeeeeee
-- 018:440000ee300444ee000444ee000333ee000000ee000000eeeeeeeeeeeeeeeeee
-- 019:e0000044ee000003eee00000eeee0000eeeee0e0eeeeee0eeeeeeee0eeeeeeee
-- 020:3000000e300000ee00000eee0000eeeee00eeeee00eeeeee0eeeeeeeeeeeeeee
-- 021:eeeeee4eeee4ff99eef22dd9efff2dd9ef0fffffeff0f000ef0f0f00effff000
-- 022:eeee4eeef4ff3eeed6d33feed6d3fffeffff0ffe000000fe00000ffe000000fe
-- 023:eff0f000efff0f00eff0f000ef0fff00eff0f000efff0f00eff0f000ef0f0f00
-- 024:00000ffe000000fe00000ffe000000fe00000ffe000000fe00000ffe000000fe
-- 025:0eeeeee0eeeffeeeeeffffeeeffffffeeffeeffeeeeeeeeefeeeeeef0ffffff0
-- 026:0eeeeee0eeeeeeeeeffeeffeeffffffeeeffffeeeeeffeeefeeeeeef0ffffff0
-- 027:0eeeeee0eeffeeeeeefffeeeeeefffeeeefffeeeeeffeeeefeeeeeef0ffffff0
-- 028:0eeeeee0eeeeffeeeeefffeeeefffeeeeeefffeeeeeeffeefeeeeeef0ffffff0
-- 033:eeeeeeeeeeeeeee0eeeeee00eeeee000eeee0000eee00000ee0e0004e0e00034
-- 034:feeeeeee0feeeeee00feeeee000feeee0000feee00000fee400000fe440000fe
-- 049:e00e0033ee000000eee00000eeee0000eeeee000eeeeee00eeeeeee0eeeeeeee
-- 050:400000fe000000fe040000ee34400eee3444eeee034eeeee00eeeeee0eeeeeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53aa7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f4243423566c86333c57
-- </PALETTE>

