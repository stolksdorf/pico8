pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
dev=true

function _init()

	load_map()
end





function troop_link(n1,n2,team)

end

function add_troop(n1,n2)
	add(troops, {
		s={x=n1.x,y=n1.y},
		e={x=n2.x,y=n2.y},

		max_dist=sqrt((n1.x-n2.x)^2+(n1.y-n2.y)^2),
		dist=0,
		spd=3,
		_t=0
	})
end




function node_dir(n1,n2,dr)
	return (dr==⬆️ and n1.y<n2.y)
		or (dr==⬇️ and n1.y>n2.y)
		or (dr==⬅️ and n1.x<n2.x)
		or (dr==➡️ and n1.x>n2.x)
end


function get_near_node(ndoe,dr)
	local bst_dst=999
	local res_idx
	for i,n in pairs(nodes) do
		local _dist=dist(node,n)

		if(_dist<bst_dst
			and node_dir(node,n,dr)) then
			res_idx=i
			bst_dst=_dist
		end
	end
	return res_idx
end
-->8
--utils



function test()

end


function animate(spd,frms)
	local t=0
	return function()
		t+=1
		if(t==spd) t=0
		local f=flr(t/spd*#frms)
		return frms[f+1]
	end
end



logs={}
function log(...)
	add(logs,join(mp({...}, function(v)
		return prt(v)
	end)," "))
end
function draw_logs()
	for i,l in pairs(logs) do
		print(l,0,i*8,8)
	end
	logs={}
end


function prt(x)
	if(type(x)=="table") then
		return "{"..join(mp(x, function(v,k)
			if(type(k)=="number") then
				return prt(v)
			else
				return k.."="..prt(v)
			end
		end),",").."}"
	end
	return tostr(x)
end


function join(t,s)
	local r=t[1]
	for i=2,#t do	r=r..s..t[i] end
	return r
end

function mp(t,fn)
	local r={}
	for k,v in pairs(t) do r[k]=fn(v,k) end
	return r
end

function rd(t,fn,acc)
	local r=acc
	for k,v in pairs(t) do acc=fn(acc,v,k) end
	return r
end



function sort(a,cmp)
	for i=1,#a do
		local j=i
		while j>1 and cmp(a[j-1],a[j]) do
			a[j],a[j-1]=a[j-1],a[j]
			j=j-1
		end
	end
	return a
end

function alpha(n)
	return sub("abcdefghijklmnopqrstuvwxyz",n,n)
end

function tiny(n)
	return sub("\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79\80\81\82\83\84\85\86\87\88\89\90\91\92",n,n)
end


function dist(a,b,x,y)
	return sqrt((a-x)^2+(b-y)^2)
end


--fade
--dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}

-->8
--draw
function _draw()
	cls()
	draw_links()
	draw_nodes()
	draw_cur()
	draw_fcs()

	if(dev) draw_logs()
end

function draw_nodes()
	for i in pairs(nx) do
		local x,y=nx[i],ny[i]
		local t,s,c=inf(i)

		if(is_safe(i)) then
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

		--if producing, whitecircle
		--different stages of full

		--print(alpha(i),x-7,y-6,7)
		--print(size[i],x+3,y-6,c)--tm_clr[i])

		if(dev) print(i,x-6,y-6,7)
	end
end

function highlight_link(n1,n2)
	local x,y=pos(n1)
	local a,b=pos(n2)
	line(x+1,y+1,a+1,b+1,7)
	line(x-1,y+1,a-1,b+1,7)
	line(x+1,y-1,a+1,b-1,7)
	line(x-1,y-1,a-1,b-1,7)
end

function draw_links()
	for a,l in pairs(links) do
		for b in all(l) do
			line(nx[a],ny[a],
								nx[b],ny[b],6)
		end
	end
end


--draw the selected box
function draw_fcs()
	rectfill(0,100,20,120,5)
	rectfill(1,101,19,119,0)
	if(cur_fcs) then
		local t,s=team[cur_fcs],size[cur_fcs]
		print(s,9,108,tm_clr[t])
	end

end


function draw_troops()
	pal(6,3)
	for t in all(troops) do
		local d=t.dist/t.max_dist
		local x=(1-d)*t.s.x+d*t.e.x
		local y=(1-d)*t.s.y+d*t.e.y

		spr(3,x-3,y-3)
	end
	pal()
end

function draw_cursor()
	local s_node=nodes[cur.n_idx]
	local x,y=s_node.x,s_node.y
	local d=cur.frames[cur.ani]

	spr(5,x-8-d,y-8-d,1,1,false,false)
	spr(5,x+0+d,y-8-d,1,1,true,false)
	spr(5,x-8-d,y+0+d,1,1,false,true)
	spr(5,x+0+d,y+0+d,1,1,true,true)
end
-->8
--updates

function _update()
	if(dev) test()

	update_cur()

end




function check_input()
	local temp=get_press()
	if(temp) then
		local t=nodes[2]
		cur.n_idx=get_near_node(t,temp)
	end

end


function update_cur()
	cur.spd-=1
	if(cur.spd<0) then
		cur.spd=8
		cur.ani=(cur.ani%#cur.frames)+1
	end
end

function update_troops()
	for t in all(troops) do
		t._t-=1
		if(t._t<=0) then
			t._t=t.spd
			t.dist+=1

			--reached the distination
			if(t.dist>t.max_dist) then
				del(troops, t)
			end

		end
	end
end


-->8
--cursor

cur_fcs=false
curx=64
cury=64
cura=animate(25,{0,1})

function update_cur()
	log(cur_fcs)

	cur_mov()

	if(btn()==0) check_snap()
end

function draw_cur()
	local x,y=curx,cury
	local d=cura()
	if(cur_fcs==false) d=-1

	spr(5,x-8-d,y-8-d,1,1,false,false)
	spr(5,x+0+d,y-8-d,1,1,true,false)
	spr(5,x-8-d,y+0+d,1,1,false,true)
	spr(5,x+0+d,y+0+d,1,1,true,true)

end

function cur_mov()
	if(btn()>0) then
		cur_fcs=false
	end
	if(btn(⬆️)) cury-=3
	if(btn(⬇️)) cury+=3
	if(btn(⬅️)) curx-=3
	if(btn(➡️)) curx+=3

	-- put in bounds?

end

function check_snap()
	local t=rank_nodes(curx,cury)[1]
	local tx,ty=pos(t)
	--log(rank_nodes2(curx,cury))

	if(dist(curx,cury,tx,ty)<12) then
		cur_fcs=t
		curx,cury=tx,ty
	end
end


-->8
--game

tm_clr={12,9,11,14}
orders={{},{},{},{}}

troop_max=5

troops={}


function deploy(home,target)
--	attempt to sub one
-- add a troop to the
end

-->8
--map
nx={}
ny={}
links={}
size={}
team={}

maplmtx={20,120}
maplmty={20,120}

function load_map()
	nx={56,82,40,30,55,80 }
	ny={16,32,99,80,40,90}


	--change this to prox
	-- built by link table
	links={
		{2,5},
		{1,5,6},
		{4,6},
		{3,5},
		{1,2,4},
		{2,3}
	}
	team={1,0,2,2,4,2}
	size={3,0,1,5,1,3}
end


function inf(n)
	return team[n],size[n],tm_clr[team[n]]
end

function pos(n)
	return nx[n],ny[n]
end

--ranks all nodes based on dist
--[[
function rank_nodes(n)
	local t={}
	local x,y=nx[n],ny[n]
	for i=1,#nx do
		if(i!=n) add(t,i)
	end

	return sort(t, function(a,b)
		return dist(nx[a],ny[a],x,y)
			> dist(nx[b],ny[b],x,y)
	end)
end
]]--

function rank_nodes(x,y,ign)
	local t={}
	for i=1,#nx do
		if(i!=ign) add(t,i)
	end
	return sort(t, function(a,b)
		return dist(nx[a],ny[a],x,y)
			> dist(nx[b],ny[b],x,y)
	end)
end

--[[
-- radix sort
function rank_nodes3(x,y)
	function dst(a,b,x,y)
		return abs(a-x)+abs(b-y)
	end

	local r={}
	for i=1,#nx,1 do
		local d=dst(nx[i],ny[i],x,y)
--		r[d]=
	end
end
--]]

function is_safe(n)
	local safe,tm=true,team[n]
	for i in all(links[n]) do
		if(team[i]==0 or tm!=team[i]) safe=false
	end
	return safe
end

-->8
-- todo
--[[
- add in a growth timer
 - once safe, start
- overflow check
  - if add, and max + links
  - send troop to each link

- add a really basic order
  processor

- troop collision
- troop invasion

- pop-up text
- troop particles



]]--
__gfx__
00000000000000000000000000000000000660000000000000000000000000000000000000000000000770000000000000000000000000000000000000000000
00000000000000000006600000000000006666000000000000055000000550000005500000099000007007000000000000000000000000000000000000000000
00700700000660000066660000077000066666600000000000555500005555000059950000999900070000700000000000000000000000000000000000000000
00077000006666000666666000766700666666660006660005555550055995500599995009999990700000070000000000000000000000000000000000000000
00077000006666000666666000766700666666660006000005555550055995500599995009999990700000070000000000000000000000000000000000000000
00700700000660000066660000077000066666600006000000555500005555000059950000999900070000700000000000000000000000000000000000000000
00000000000000000006600000000000006666000000000000055000000550000005500000099000007007000000000000000000000000000000000000000000
00000000000000000000000000000000000660000000000000000000000000000000000000000000000770000000000000000000000000000000000000000000
00000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000076670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666000000666000766667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600000000006007666666700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600006600006007666666700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066660000000766667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666000000076670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666600000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600006600006000000000000000000000000000000000000000000000880000000000000000000000000000000000000000000000000000000000000000000
00600000000006000000000000000000000000000000000000000000000880000000000000000000000000000000000000000000000000000000000000000000
00666000000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900002355022550225502355023550235502255022550225502355023550235502355000550185502455024550245502455024550245502455023550005000050000500005000050000500005000050000500
