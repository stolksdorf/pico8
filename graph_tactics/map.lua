--map


nodes={}
links={}


function init_map()
	-- calc all nbhrs for each node
	-- calc all link lengths

	for node in all(nodes) do
		node.tick=1
		node.nbhrs={}
	end

	for link in all(links) do
		link.len=node_dist(link.a,link.b)
		add(nodes[link.a].nbhrs, link.b)
		add(nodes[link.b].nbhrs, link.a)
	end

end


function update_map()
	--calc node safety

	for n in all(nodes) do
		n.safe=is_safe(n)
	end

end

function draw_map()

	draw_links()
	draw_nodes()

end

function draw_links()
	for l in all(links) do
		local x,y=pos(l.a)
		local a,b=pos(l.b)
		line(x,y,a,b,drk_gry)
	end



	-- ARROWS
	for i,cmd in pairs(hero().cmds) do
		local x,y=pos(cmd.from)
		local a,b=pos(cmd.dest)
		line(x,y,a,b,lgt_gry)
	end

	if(view=='cmds') then
		local cmd = hero().cmds[cmd_fcs]
		local x,y=pos(cmd.from)
		local a,b=pos(cmd.dest)
		line(x,y,a,b,blue)
	end

end

function draw_nodes()
	for i,n in pairs(nodes) do

		-- if(is_safe(i) then
		-- 	spr(10,n.x-4,n.y-4)
		-- end


		-- local fill=0
		-- for i,v in pairs({0,1,3,5}) do
		-- 	if(n.size>=v) then
		-- 		fill=i-1
		-- 	end
		-- end




		--
		if(fog==true and is_vsbl(n, active_plyr)==false) then

			pal(2, 0)
			spr(sp.med,n.x-4,n.y-4)
			pal()
		else

			local s=sp.empty
			if(n.size==1) then s=sp.low end
			if(n.size>1) then s=sp.med end
			if(n.size==max_size(plyrs[n.team])) then s=sp.max end





			color(n.team)
			spr(s,n.x-4,n.y-4)

			if(n.safe and n.team!=false) then
				spr(sp.safe,n.x-4,n.y-4)
			end

			--if(dev) print(tiny(i),n.x-6,n.y-6,6)

			--if(dist(cur_x,cur_y,n.x,n.y) < 30) print(tiny(i),n.x-6,n.y-6,5)

			local lx,ly=lbl_quad(n)

			print(tiny(i),lx,ly,drk_gry) --label


		end


		--print(n.size, n.x+6, n.y-6, red)
	end
	pal()
end

function lbl_quad(n)
	local ul,ur,ll,lr=true,true,true,true


	for i in all(n.nbhrs) do
		if(nodes[i].x > n.x and nodes[i].y > n.y) then lr=false end
		if(nodes[i].x < n.x and nodes[i].y > n.y) then ll=false end
		if(nodes[i].x > n.x and nodes[i].y < n.y) then ur=false end
		if(nodes[i].x < n.x and nodes[i].y < n.y) then ul=false end
	end


	if(ul) return n.x-6,n.y-6
	if(ur) return n.x+4,n.y-6
	if(ll) return n.x-6,n.y+3
	if(lr) return n.x+4,n.y+3

	return n.x-6,n.y-6
end



--[[
function draw_nodes2()
	for i in pairs(nx) do
		local x,y=nx[i],ny[i]
		local t,s,c=inf(i)

		if(is_safe(i) then
			spr(10,x-4,y-4)
		end

		--starts at spr 6
		local _s=2
		if(s==0) _s=0
		if(s==1) _s=1
		if(s>=5) _s=3

		--_s=flr(s/4*troop_max)



		pal(9,c)
		spr(6+_s,x-4,y-4)
		pal()

		--if(producing, whitecircle
		--different stages of full

		--print(alpha(i),x-7,y-6,7)
		--print(size[i],x+3,y-6,c)--tm_clr[i])

		if(dev) print(i,x-6,y-6,8)
	end
end
--]]


--[[
function highlight_link(n1,n2)
	local x,y=pos(n1)
	local a,b=pos(n2)
	line(x+1,y+1,a+1,b+1,7)
	line(x-1,y+1,a-1,b+1,7)
	line(x+1,y-1,a+1,b-1,7)
	line(x-1,y-1,a-1,b-1,7)
end
]]--



--[[
function check_input()
	local temp=get_press()
	if(temp) then
		local t=nodes[2]
		cur.n_idx=get_near_node(t,temp)
	end

end
]]--


-- utils


function inf(i)
	local n=nodes[i]
	return n.team,n.size,colors[n.team]
end

function pos(n)
	return nodes[n].x,nodes[n].y
end

function get_link(a,b)
	for i,l in pairs(links) do
		if(a==l.a and b==l.b) then return l end
		if(b==l.a and a==l.b) then return l end
	end
end

--function node_dist(a,b)
--	return dist(nx[a],ny[a],nx[b],ny[b])
--end


function rank_nodes(x,y,ign)
	local t={}
	for i=1,#nodes do
		if(i!=ign) then add(t,i) end
	end
	return sort(t, function(a,b)
		local x1,y1=pos(a)
		local x2,y2=pos(b)
		return dist(x1,y1,x,y)
			> dist(x2,y2,x,y)
	end)
end

function is_safe(node)
	local safe=true
	for i in all(node.nbhrs) do
		if(nodes[i].team != node.team) then safe=false end
	end
	return safe
end

function is_vsbl(node, team)
	if(node.team==team) then return true end
	--local vsbl=false
	for i in all(node.nbhrs) do
		if(nodes[i].team == team) then return true end
	end
	return false
end


-- function is_safe_old(n)
-- 	local safe,tm=true,nodes[n].team
-- 	for i in all(nodes[n].prox) do
-- 		local _tm=nodes[i].team
-- 		if(_tm==0 or tm!=_tm) then safe=false
-- 	end
-- 	return safe
-- end