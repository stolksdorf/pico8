pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()


end

tmp=0
function _update()
	tmp+=1
	log("yo ", tmp)
end


function _draw()
	cls()
	log("moar logs 웃")
	shadow_text("yo yo yo",10,10)


	draw_logs()
end
-->8
-- utils

function animate(spd,frms)
	local t=0
	return function()
		t+=1
		if(t==spd) t=0
		local f=flr(t/spd*#frms)
		return frms[f+1]
	end
end

function shadow_text(txt,x,y,c,s)
	c=c or 6
	s=s or 1
	print(txt,x+1,y+1,s)
	print(txt,x,y+1,s)
	print(txt,x+1,y,s)
	print(txt,x,y,c)
end

--Logging
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
	for i=2,#t do r=r..s..t[i] end
	return r
end

function mp(t,fn)
	local r={}
	for k,v in pairs(t) do r[k]=fn(v,k) end
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

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
