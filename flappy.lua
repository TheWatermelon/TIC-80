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
GAMESTATE=GAME

t=0
x=56
y=24
-- gravity is a negative value
jump_gravity=-0.05
-- speed is initial velocity
-- relative velocity is velocity(x) = speed + gravity * x
-- relative position is position(x) = 0.5 * gravity * x^2 + speed * x
jump_speed=1.2
-- timer acts as x value in f(x) = gravity * x^2 + speed * x 
jump_timer=0
score=0

pipes = {}

function modulo(a,b)
	return a-math.floor(a/b)*b
end

function generate_pipe(index)
	-- pipe[1] -> pipe_x
	if index==1 then
		if pipes[index][1]<240 then
			pipes[index][1] = pipes[4][1]+pipes[4][4]
		end
	else
		pipes[index][1] = pipes[index-1][1]+pipes[index-1][4]
	end
	-- pipe[2] -> pipe_top_y
	pipes[index][2]=math.random(15,90)
	-- pipe[3] -> pipe_space
	pipes[index][3]=math.random(36,54)
	-- pipe[4] -> inter pipe space
	pipes[index][4]=math.random(80,100)
end

function initialize_pipes()
	for i=1,4 do
		pipes[i] = {240,0,0,90}
		generate_pipe(i)
	end
end

function move_pipes()
	for i=1,4 do
		pipes[i][1]=pipes[i][1]-1
		if pipes[i][1]<-16 then generate_pipe(i) end
	end
end

function get_jump_velocity()
	-- the velocity is positive until max height then negative
	return jump_speed+jump_gravity*jump_timer
end

function fall_bird()
	-- positive velocity -> bird move up
	-- negative velocity -> bird move down
	y=y-get_jump_velocity()
	-- GAME OVER BY OUT OF BOUNDS
	if y<0 then y=0 elseif y>120 then y=120 end
end

function check_collision()
	collision=false

	-- tic collision box is a 2x2 box in the middle of the sprite
	tic_x1=x+8
	tic_x2=tic_x1+2
	tic_y1=y+6
	tic_y2=tic_y1+2

	for i=1,4 do
		-- box represents inner space between pipes
		box_x1=pipes[i][1]+1
		box_x2=box_x1+14
		box_y1=pipes[i][2]+4
		box_y2=pipes[i][2]+pipes[i][3]+3
		
		if ((tic_x1>=box_x1 and tic_x1<=box_x2) or (tic_x2>=box_x1 and tic_x2<=box_x2)) and (tic_y1<=box_y1 or tic_y2>=box_y2) then
			collision=true
			break
		end
		if tic_x1==box_x2 then score=score+1 end
	end
	return collision
end

function start_jump()
	jump_timer=0
end

-- RUN ONCE BEFORE LOOP
initialize_pipes()

-- LOOP
function TIC()
	if GAMESTATE==MENU_MAIN then
		-- explains commands
		if btnp(4) then GAMESTATE=GAME end
	elseif GAMESTATE==MENU_PAUSE then
		if btnp(4) then GAMESTATE=GAME end 
	elseif GAMESTATE==MENU_GAME_OVER then
		rect(50,40,138,35,0)
		rectb(49,39,140,37,12)
		print("GAME OVER",90,50,12,true,1,false)
		print("PRESS  TO START OVER",60,60,12,true,1,false)
		spr(10,92,59,0,1,0,0,1,1)

		if btnp(5) then GAMESTATE=MENU_MAIN end
	elseif GAMESTATE==GAME then
		-- btn(0) : UP ARROW
		-- btn(1) : DOWN ARROW
		-- btn(2) : LEFT ARROW
		-- btn(3) : RIGHT ARROW
		-- btn(4) : Z (A ON CONTROLLER)
		if btnp(4) then start_jump() end
		-- btn(5) : X (B ON CONTROLLER)
		-- btn(6) : A (X ON CONTROLLER)
		-- btn(7) : S (Y ON CONTROLLER)

		cls(14)
		-- TIC sprite
		spr(1+t%60//30*2,x,y,14,1,0,1,2,2)
		for p=1,4 do
			for i=pipes[p][2]-8,-8,-8 do
				spr(7,pipes[p][1],i,14,1,0,0,2,1)
			end
			spr(5,pipes[p][1],pipes[p][2],14,1,0,0,2,1)
			spr(21,pipes[p][1],pipes[p][2]+pipes[p][3],14,1,0,0,2,1)
			for i=pipes[p][2]+pipes[p][3]+8,136,8 do
				spr(23,pipes[p][1],i,14,1,0,0,2,1)
			end

			pix(pipes[p][1]+1,pipes[p][2]+4,2)
			pix(pipes[p][1]+14,pipes[p][2]+4,2)
			pix(pipes[p][1]+1,pipes[p][2]+pipes[p][3]+3,2)
			pix(pipes[p][1]+14,pipes[p][2]+pipes[p][3]+3,2)

			rect(x+8,y+6,2,2,6)
		end
		-- INFO
		print(score,8,8,12,true,1,false)
		-- B BUTTON
		spr(10,190,7,0,1,0,0,1,1)
		print("PAUSE",200,8,12,true,1,false)

		fall_bird()
		move_pipes()
		--if check_collision() then GAMESTATE=MENU_GAME_OVER end
		print(check_collision(),16,8,12,true,1,false)

		jump_timer=jump_timer+1
	end
	t=t+1
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 005:effff000ef0f0f00eff0f000ef0fffffefff2dd9eef22dd9eee2ff49eee4eeee
-- 006:00000ffe000000fe00000ffeffff00fed6d3fffed6d33feef6ff4eeee4eeeeee
-- 007:eff0f000ef0fff00eff0f000efff0f00eff0f000ef0fff00eff0f000efff0f00
-- 008:00000ffe000000fe00000ffe000000fe00000ffe000000fe00000ffe000000fe
-- 009:0555555055566555556556555566665555655655556556556555555606666660
-- 010:0222222022111222221221222211122222122122221112221222222101111110
-- 011:0aaaaaa0aa9aa9aaaa9aa9aaaaa99aaaaa9aa9aaaa9aa9aa9aaaaaa909999990
-- 012:0444444044344344443443444443334444444344443334443444444303333330
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 021:eeeeee4eeee4ff49eef22dd9efff2dd9ef0fffffeff0f000ef0f0f00effff000
-- 022:eeee4eeef4ff4eeed6d33feed6d3fffeffff0ffe000000fe00000ffe000000fe
-- 023:eff0f000efff0f00eff0f000ef0fff00eff0f000efff0f00eff0f000ef0f0f00
-- 024:00000ffe000000fe00000ffe000000fe00000ffe000000fe00000ffe000000fe
-- 025:0eeeeee0eeeffeeeeeffffeeeffffffeeffeeffeeeeeeeeefeeeeeef0ffffff0
-- 026:0eeeeee0eeeeeeeeeffeeffeeffffffeeeffffeeeeeffeeefeeeeeef0ffffff0
-- 027:0eeeeee0eeffeeeeeefffeeeeeefffeeeefffeeeeeffeeeefeeeeeef0ffffff0
-- 028:0eeeeee0eeeeffeeeeefffeeeefffeeeeeefffeeeeeeffeefeeeeeef0ffffff0
-- 116:00000000000000000000000000000f0000000000000000000000000000000000
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53aa7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f4243423566c86333c57
-- </PALETTE>

