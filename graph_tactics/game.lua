--game
-- hero=1
-- plyr={}
-- troops={}

plyrs={}

function init_game()
	-- plyr[1]={
	-- 	clr=12,
	-- 	cmds={
	-- 		{s=1,e=5,_t=0,a=true},
	-- 		{s=2,e=6,_t=20,a=true},
	-- 		{s=2,e=6,_t=0,a=false},
	-- 	}
	-- }

	-- plyr[2]={
	-- 	clr=9,
	-- 	cmds={}
	-- }

	--plyrs={}

	for link in all(links) do
		link.troops={}
	end
end

function update_game()
	update_cmds()
	update_troops()
	update_nodes()
end


function draw_game()
	draw_cmds()
	draw_troops()
end

----------------------








-- function draw_timer(x,y,p)
-- 	spr(48+flr(13*p),x,y)
-- end


function deploy(from,dest)
--	attempt to sub one
-- add a troop to the

	local home=nodes[from]

	if(home.size<=1) then
		--hvrtxt("oof", home.x, home.y)
		return
	end


	local x,y=pos(from)

	--hvrtxt("deploy",x-4,y)

	local link=get_link(from,dest)
	local dir,p = 1,0
	if(link.a==dest) then dir,p=-1,1 end


	home.size -= 1
	add(link.troops, {
		dir=dir,
		p=p,
		team=home.team,
		--dest=dest
	})



	-- local a,b=nodes[from],nodes[dest]

	-- if(size[from]<=1) return

	-- size[from]-=1
	-- add(troops,{
	-- 	srt=from,
	-- 	trg=dest,
	-- 	lnk=get_link(from,dest),
	-- 	tm=team[from],
	-- 	dist=0,
	-- 	_a=0
	-- })
end

--maybe build a array builder?

-- function update_scores()
-- 	scores={0,0,0,0}
-- 	for t in all(team) do
-- 		if(t!=0) then scores[t]+=1 end
-- 	end
-- end


function get_scores()
	local scores={}

	for i,p in pairs(plyrs) do
		scores[i]=0
	end

	for n in all(nodes) do
		if(n.team != false) then
			scores[n.team] += 1
		end
	end
	return scores
end


-- COMMANDS --

function create_cmd(plyr_id, from, dest)
	hvrtxt('CMD', 4 + 15, 30 + 8 * #plyrs[plyr_id].cmds)
	add(plyrs[plyr_id].cmds, {
		from=from,
		dest=dest,
		tick=0
	})
end

function verify_cmds()
	for i,p in pairs(plyrs) do
		local _cmds={}
		for c in all(p.cmds) do
			--add(_cmds, c.from..c.dest)
			-- player owns from node
			-- from and dest have a link
			-- is not a duplicate
		end
	end
end


function update_cmds()
	for p in all(plyrs) do
		local p_tick=cmd_speed(p) --add ratio in here #p.cmds
		for c in all(p.cmds) do
			c.tick+=p_tick
			if(c.tick>=1) then
				c.tick=0
				deploy(c.from,c.dest)
			end
		end
	end
end



function draw_cmds()
	--log(active_plyr)
	--log(hero())

	-- TABLE
	local x,y=4,30
	print("cmds", x, y+4, hero().color)
	-- display current order execution speed
	for i,cmd in pairs(hero().cmds) do
		local from = nodes[cmd.from]
		local dest = nodes[cmd.dest]
		local spc = 8 * i

		print(alpha(cmd.from).."  "..alpha(cmd.dest), x, y+4+spc, lgt_gry)
		spr(21, x+3, y+3+spc) --arrow
		line(x, y+3+spc, x+15*cmd.tick, y+3+spc, red)
	end

end


-- function draw_cmds()
-- 	local x,y=0,25
-- 	local w,h=28,50

-- 	rect(x,y,x+w,y+h,6)
-- 	line(x,y+10,x+w,y+10)
-- 	print("cmds",x+3,y+3)

-- 	for i,o in pairs(main_plyr.cmds) do
-- --		local txt=alpha(o.s).."  "..alpha(o.e)
-- 		local txt=o.s.."  "..o.e
-- 		local x,y=x+2,y+5+i*8

-- 		print(txt,x,y,6)
-- 		spr(21,x+3,y-1)

-- 		rectfill(x+18,y+1,x+23,y+3,5)
-- 		rectfill(x+18,y+1,x+18+5*o._t/100,y+3,9)

-- 		--line(x,y,x+w*o._t/100,y,13)
-- 		--draw_timer(x,y,o._t/100)

-- 	end
-- end


-- function pos_2_nodes(n1,n2,p)

-- 	return (n2.x-n1.x)*p+n1.x,
-- 		(n2.y-n1.y)*p+n1.y,

-- end


function update_troops()

	for link in all(links) do

		-- move troop
		for t in all(link.troops) do
			t.p += t.dir*troop_speed
			if(t.p<0 or t.p>1) then
				local dest = cond(t.dir==1, link.b, link.a)
				invade(dest, t.team)
				del(link.troops, t)
			end
		end

		function chk_fght(a,b)
			if(a.team!=b.team) then
				if(abs(a.p-b.p) < 0.02) then
					del(link.troops, a)
					del(link.troops, b)
				end
			end
		end

		for a in all(link.troops) do
			for b in all(link.troops) do
				chk_fght(a,b)
			end
		end
	end


end


function own_link(link, team)
	return nodes[link.a].team==team or nodes[link.b].team==team
end

function draw_troops()
	for link in all(links) do

		if(fog==true and own_link(link, active_plyr)) then

			local ax,ay=pos(link.a)
			local bx,by=pos(link.b)
			for t in all(link.troops) do
				local x=(bx-ax)*t.p+ax
				local y=(by-ay)*t.p+ay

				color(t.team)
				spr(sp.troop, x-3, y-3)
			end

		end
	end
	pal()
end


function invade(n,team)
	local node = nodes[n]

	if(node.team != team) then
		node.size -= 2

		if(node.size<1) then
			node.team=team
			node.size=1
			hvrtxt("⌂",node.x,node.y, color(team))
		end


	else
		node.size+=1
	end
end

function check_troops()

end






function update_nodes()

	for n in all(nodes) do
		local plyr=plyrs[n.team]

		--TODO: replace with function call
		if(n.safe!=true) then
			n.tick=1
		else
			n.tick-=grow_spd(plyr)
		end

		if(n.tick<0) then
			n.tick=1
			n.size+=1
		end

		if(n.size>max_size(plyr)) then
			n.size=max_size(plyr)
		end
	end

end



-- -- you gotta remove
-- function troop_xy(t)
-- 	local d=t.dist/node_dist(t.srt,t.trg)
-- 	local sx,sy=pos(t.srt)
-- 	local tx,ty=pos(t.trg)

-- 	local x=(1-d)*sx+d*tx
-- 	local y=(1-d)*sy+d*ty
-- 	return x,y
-- end




function draw_score()
	local x,y,w,h=1,15,25,4
	local t,j=0
	rect(x-1,y-1,x+w,y+h+1,5)
	for i,s in pairs(get_scores()) do
		if(s!=0) then
			j=(s/#nodes)*w
			rectfill(x+t,y,x+j+t,y+h,plyrs[i].color)
			t+=j
		end
	end
end