--utils



function test()

	--log({a=1,b=2,c=3})
	--log(nodes[1])

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
	--return n
	return sub("abcdefghijklmnopqrstuvwxyz",n,n)
end

function tiny(n)
	--return n
	return sub("ABCDEFGHIJKLMNOPQRSTUVWXYZ",n,n)
end

function node_dist(a,b)
	return dist(
		nodes[a].x,
		nodes[a].y,
		nodes[b].x,
		nodes[b].y)
end

function each(lst, fn)
	local r,i={},0
	for k,v in pairs(lst) do
		r[i]=fn(v,k,i)
		i+=1
	end
	return r
end

function dist(a,b,x,y)
	return sqrt((a-x)^2+(b-y)^2)
end

function clamp(val, _min, _max)
	if(val<_min) return _min
	if(val>_max) return _max
	return val
end

function modu(val, cap)
	if(val==0) return cap
	if(val<0) return cap+val
	if(val>cap) return val-cap
	return val
end


function shadow_text(txt,x,y,c,s)
	c=c or 6
	s=s or 1
	print(txt,x+1,y+1,s)
	print(txt,x,y+1,s)
	print(txt,x+1,y,s)
	print(txt,x,y,c)
end

function animate(spd,frms)
	local t=0
	local frm=frms[1]
	return {
		get=function()
			return frm
		end,
		update=function()
			t+=1
			if(t==spd) t=0
			frm=frms[flr(t/spd*#frms)+1]
		end
	}
end

function quad(val,func)
	func(val,val)
	func(0,val)
	func(val,0)
	func(0,0)
end

function cond ( test , T , F )
	if(test) then return T else return F end
end


-- colors

--team_colors={3,4,5}

function color(team)
	local clr=5
	if(team!=false) then clr=plyrs[team].color end
	pal(2, clr)
	return clr
end

drk_gry=5
lgt_gry=6
white=7

red=8
blue=12
green=3
purple=13
orange=9
yellow=10

fill=2


-- SPRITES
sp={
	cur=5,
	cur_o=4,
	cur_s=3,

	cmd_cnl=19,


	empty=6,
	low=7,
	med=8,
	max=9,
	safe=11,
	unkn=22,

	troop=34
	--troop=35
}