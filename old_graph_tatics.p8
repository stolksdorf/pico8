pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--graph tatics
--by:scott tolksdorf

dev=true

function _init()


	load_map()
end


t=-1
function upt()

	--replace with orders
--	t+=1
--	if(t%80==0) deploy(4,5)
--	if(t%70==0) deploy(1,2)
--	if(t%65==0) deploy(5,1)
--	if(t%70==0) deploy(1,5)

end
-->8
--utils


function test()

	--log({a=1,b=2,c=3})

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



_logs={}
function log(...)
	add(_logs,join({...}," ",prt))
end
function draw_logs()
	for i,l in pairs(_logs) do
		print(l,0,i*8,8)
	end
	_logs={}
end

function prt(x)
	if(type(x)=="table") then
		return "{"..join(x,",",function(v,k)
			if(type(k)=="number") then
				return prt(v)
			else
				return k.."="..prt(v)
			end
		end).."}"
	end
	return tostr(x)
end

function noop(x) return x end

function join(t,s,fn)
	fn=fn or noop
	local r=""
	for k,v in pairs(t) do
		if(r!="") r=r..s
		r=r..fn(v,k)
	end
	return r
end

--function mp(t,fn)
--	local r={}
--	for k,v in pairs(t) do r[k]=fn(v,k) end
--	return r
--end
--
--function rd(t,fn,acc)
--	local r=acc
--	for k,v in pairs(t) do acc=fn(acc,v,k) end
--	return r
--end
--


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

function shadow_text(txt,x,y,c,s)
	c=c or 6
	s=s or 1
	print(txt,x+1,y+1,s)
	print(txt,x,y+1,s)
	print(txt,x+1,y,s)
	print(txt,x,y,c)
end


--fade
--dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}

-->8
--draw
function _draw()
	cls()
	draw_links()
	draw_troops()
	draw_nodes()

	draw_cur()
	draw_fcs()
	draw_score()
	draw_orders()

	draw_hvrtxt()
	draw_particles()

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

		if(dev) print(i,x-6,y-6,8)
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
	for l in all(links) do
		local x,y=pos(l[1])
		local a,b=pos(l[2])
		line(x,y,a,b,6)
	end
end


--draw the selected box
function draw_fcs()
	local x,y=0,100
	rectfill(x,y,x+20,y+20,5)
	rectfill(x+1,y+1,x+19,y+19,0)
	if(cur_fcs) then
		local t,s,c=inf(cur_fcs)
		print(s,x+9,y+8,c)
	end

end


function troop_xy(t)
	local d=t.dist/node_dist(t.srt,t.trg)
	local sx,sy=pos(t.srt)
	local tx,ty=pos(t.trg)

	local x=(1-d)*sx+d*tx
	local y=(1-d)*sy+d*ty
	return x,y
end

function draw_troops()
	for t in all(troops) do
		local x,y=troop_xy(t)
		pal(2,tm_clr[t.tm])
		spr(3,x-3,y-3)
	end
	pal()
end

--make this (x,y,d,c)
function draw_cursor()
	local s_node=nodes[cur.n_idx]
	local x,y=s_node.x,s_node.y
	local d=cur.frames[cur.ani]

	spr(5,x-8-d,y-8-d,1,1,false,false)
	spr(5,x+0+d,y-8-d,1,1,true,false)
	spr(5,x-8-d,y+0+d,1,1,false,true)
	spr(5,x+0+d,y+0+d,1,1,true,true)
end


function draw_score()
	local x,y,w,h=1,15,25,4
	local t,j=0
	rect(x-1,y-1,x+w,y+h+1,5)
	for i,s in pairs(scores) do
		if(s!=0) then
			j=(s/#nx)*w
			rectfill(x+t,y,x+j+t,y+h,clrs[i])
			t+=j
		end
	end
end



function draw(lst)
	for p in all(lst) do
		p:draw()
	end
end

function draw_particles()
	draw(particles)
end
-->8
--updates

function _update()
	if(dev) test()

	upt()

	update_orders()

	update_troops()
	update_nodes()
	upd_scores()
	update_cur()
	update_hvrtxt()

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
		--t.dist+=1/5
		t.dist+=1/2

		--reached the node
		if(t.dist>=lnkdst[t.lnk]) then
			del(troops, t)
			invade(t.trg,t.tm)
		end
	end

	for a in all(troops) do
		for b in all(troops) do
			if(a.lnk==b.lnk and
			   a.tm !=b.tm  and
			   a.dist+b.dist>=lnkdst[a.lnk]) then
				del(troops,a)
				del(troops,b)
				local x,y=troop_xy(a)
			 particle(x,y,clrs[a.tm])
			 particle(x,y,clrs[b.tm])
			end
		end
	end

end

function invade(n,tm)
	if(team[n]!=tm) then
		size[n]-=2
		--conquer
		if(size[n]<1) then
			size[n]=1
			team[n]=tm
			hvrtxt("⌂",nx[n]-4,ny[n],clrs[tm])
		end
	else
		size[n]+=1
	end
end

function check_troops()

end



function update_nodes()
	for i=1,#nx do
		--overflow
		nbs=#nbhrs[i]
		if(size[i]>=nbs+troop_max) then
			size[i]-=nbs
			sfx(63)
			for n in all(nbhrs[i]) do
				deploy(i,n)
			end
		end
	end
end


-->8
--cursor

cur_fcs=false
curx=64
cury=64
cura=animate(20,{0,1})

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

	if(btnp(🅾️)) then
		particle(curx,cury,rnd(12)+1)
	end

	if(btnp(❎)) then
		particle(curx,cury,rnd(12)+1)
		particle(curx,cury,rnd(12)+1)
		particle(curx,cury,rnd(12)+1)
		particle(curx,cury,rnd(12)+1)
		particle(curx,cury,rnd(12)+1)
	end

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

--ui

hvr_txt={}

function hvrtxt(txt,x,y,c)
	c=c or 7
	add(hvr_txt,{
		txt=txt,
		x=x,
		y=y-10,
		o=10,
		c=c
	})
end

function update_hvrtxt()
	for h in all(hvr_txt) do
		h.o=h.o/1.15
		if(h.o<0.1) del(hvr_txt,h)
	end
end

function draw_hvrtxt()
	for h in all(hvr_txt) do
		shadow_text(h.txt,h.x,h.y+h.o,h.c)
	end
end
-->8
--game

tm_clr={12,9,11,14} --remove
clrs={12,9,11,14}

--each tick every player
--gets a tick

orders={}
scores={0,0,0,0}
size={}
team={}

troop_max=5

troops={}


plyrs={
	{
		clr=12,
		score=0,
		orders={
			--e -> t
			-- _t -> _
			--all _ 0~1
			{s=1,e=5,_t=0,a=true},
			{s=2,e=6,_t=20,a=true},
			{s=2,e=6,_t=0,a=false},
		},
		_tick=0,
	},
	{
		clr=9,
		score=0,
		orders={
			{s=4,e=5,_t=0},
		},
		_tick=0,
	},
}

main_plyr=plyrs[1]

function init_game()
	--set up arrays
	-- orders, score


end

function update_orders()
	for p in all(plyrs) do
		local p_tick=1 --add ratio in here
		for o in all(p.orders) do
			o._t+=p_tick
			if(o._t>100) then
				o._t=0
				deploy(o.s,o.e)
			end
		end
	end
end
function draw_orders()
	local x,y=0,25
	local w,h=28,50

	rect(x,y,x+w,y+h,6)
	line(x,y+10,x+w,y+10)
	print("orders",x+3,y+3)

	for i,o in pairs(main_plyr.orders) do
--		local txt=alpha(o.s).."  "..alpha(o.e)
		local txt=o.s.."  "..o.e
		local x,y=x+2,y+5+i*8

		print(txt,x,y,6)
		spr(21,x+3,y-1)

		rectfill(x+18,y+1,x+23,y+3,5)
		rectfill(x+18,y+1,x+18+5*o._t/100,y+3,9)

		--line(x,y,x+w*o._t/100,y,13)
		--draw_timer(x,y,o._t/100)

	end
end

function draw_timer(x,y,p)
	spr(48+flr(13*p),x,y)
end


function deploy(home,target)
--	attempt to sub one
-- add a troop to the

	if(size[home]<=1) return

	size[home]-=1
	add(troops,{
		srt=home,
		trg=target,
		lnk=get_link(home,target),
		tm=team[home],
		dist=0,
		_a=0
	})
end

--maybe build a array builder?

function upd_scores()
	scores={0,0,0,0}
	for t in all(team) do
		if(t!=0) scores[t]+=1
	end
end


particles={}
function particle(x,y,c)
	add(particles,{
		x=x,y=y,c=c,
		dx=(rnd(2)-1)/2,
		dy=(-rnd(1)-1)/1,
		t=20,
		draw=function(p)
			p.x+=p.dx
			p.y+=p.dy
			p.dy+=0.1 --grav
			p.t-=1
			pal(2,p.c)
			spr(3,p.x-4,p.y-4)
			if(p.t==0) del(particles,p)
		end
	})
end
-->8
--map
nx={}
ny={}
links={}
nbhrs={}

node={}



lnkdst={} --precalc linkdist

maplmtx={20,120}
maplmty={20,120}

function load_map()
	nx={56,82,40,30,55,80 }
	ny={16,32,99,80,40,90}

	links={
		{1,2},
		{1,5},
		{2,5},
		{2,6},
		{6,3},
		{3,4},
		{4,5}
	}

	init_map()
	--todo: bild the neighbours fn
	-- remake the draw links func
	--


	--change this to prox
	-- built by link table
	team={1,0,2,2,4,2}
	size={3,0,1,5,1,3}
end

function init_map()
	for i=1,#nx do
		nbhrs[i]={}
		node[i]={}
		--size[i]=0
		--team[i]=0
	end

	for i,l in pairs(links) do
		local a,b=l[1],l[2]
		add(nbhrs[a],b)
		add(nbhrs[b],a)
		lnkdst[i]=dist(nx[a],ny[a],nx[b],ny[b])
	end

end


function inf(n)
	return team[n],size[n],tm_clr[team[n]]
end

function pos(n)
	return nx[n],ny[n]
end

function get_link(a,b)
	for i,l in pairs(links) do
		if(a==l[1] and b==l[2]) return i
		if(b==l[1] and a==l[2]) return i
	end
end

function node_dist(a,b)
	return dist(nx[a],ny[a],nx[b],ny[b])
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
	for i in all(nbhrs[n]) do
		if(team[i]==0 or tm!=team[i]) safe=false
	end
	return safe
end

-->8
--todo
--[[
- draw a skrimish line
  where troops are meeting

- add in a growth timer
 - once safe, start


- make a plyrs obj
 - clr, ordrs,


]]--
__gfx__
00000000000000000000000000000000000660000000000000000000000000000000000000000000000770000000000000000000000000000000000000000000
00000000000000000006600000000000006666000000000000055000000550000005500000099000007007000000000000000000000000000000000000000000
00700700000660000066660000066000066666600000000000555500005555000059950000999900070000700000000000000000000000000000000000000000
00077000006666000666666000622600666666660006660005555550055995500599995009999990700000070000000000000000000000000000000000000000
00077000006666000666666000622600666666660006000005555550055995500599995009999990700000070000000000000000000000000000000000000000
00700700000660000066660000066000066666600006000000555500005555000059950000999900070000700000000000000000000000000000000000000000
00000000000000000006600000000000006666000000000000055000000550000005500000099000007007000000000000000000000000000000000000000000
00000000000000000000000000000000000660000000000000000000000000000000000000000000000770000000000000000000000000000000000000000000
00000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000076670000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666000000666000766667000000000000000000000550000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600000000006007666666700000000000000000055555000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600006600006007666666700000000000000000000550000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066660000000766667000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666000000076670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666600000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600006600006000000000000000000000000000000000000000000000880000000000000000000000000000000000000000000000000000000000000000000
00600000000006000000000000000000000000000000000000000000000880000000000000000000000000000000000000000000000000000000000000000000
00666000000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000000650000006500000065000000650000006500000065000000650000006500000065000000650000006500000055000000000000000000000000000
00666600006656000066550000665500006655000066550000665500006655000066550000665500006655000066550000555500000000000000000000000000
06666660066656600666556006665550066655500666555006665550066655500666555006665550066655500556555005555550000000000000000000000000
66655666666556666665556666655555666555556665555566655555666555556665555566655555555555555555555555555555000000000000000000000000
66655666666556666665566666655666666555556665555566655555666555556665555566555555555555555555555555555555000000000000000000000000
06666660066666600666666006666660066666600666555006665550066555500655555005555550055555500555555005555550000000000000000000000000
00666600006666000066660000666600006666000066660000665500006555000055550000555500005555000055550000555500000000000000000000000000
00066000000660000006600000066000000660000006600000065000000550000005500000055000000550000005500000055000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900002355022550225502355023550235502255022550225502355023550235502355000550185502455024550245502455024550245502455023550005000050000500005000050000500005000050000500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002b350293500030026350233501f3501c35016350113500030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300