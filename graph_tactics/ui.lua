--ui

function init_ui()
	view='nodes' --cmds, nodes

	cur_ani=animate(20, {4,5})
	cur_x=64
	cur_y=64

	cmd_fcs=1
	cmd_sel=false

	node_sel=false
	node_fcs=false

	hvr_txt={}
end


function update_ui()
	update_hvrtxt()

	cur_ani.update()

	--if(view=='nodes') then cur_ani.update() end






	if(view=='nodes') then
		hdl_cursor()
	elseif(view=='cmds') then
		hdl_cmds()
	end

	--if(view=='players') then hdl_plyrs() end

end


function draw_ui()
	draw_frame()
	draw_score()
	draw_node_fsc()


	if(view=='nodes') then draw_cursor() end
	if(view=='cmds') then
		draw_reticle(
			-2, cmd_fcs * 8 + 29,
			19, 8
		)

		if(cmd_sel!=false) then
			spr(sp.cmd_cnl, 20, cmd_fcs * 8 + 32)

		end


	end




	draw_hvrtxt()
end


--


-- function draw_cursor()
-- 	-- if(node is selected also draw the focus




-- end


function draw_frame()
	--map(0,0,0,0)

end


function draw_node_fsc()
	local x,y=2,90
	if(node_fcs==false) then return end
	local node=nodes[node_fcs]

	each({
		id=node_fcs,
		name=alpha(node_fcs),
		size=node.size,
		safe=cond(is_safe(node),'Y', 'N'),
		vsbl=cond(is_vsbl(node, active_plyr),'Y', 'N')
	}, function(v,k,i)
		print(k..':',x,y+i*6, blue)
		print(v,x+20,y+i*6, red)
	end)
end



function hdl_cursor()
	if(btn(⬆️)) then cur_y-=3 end
	if(btn(⬇️)) then cur_y+=3 end
	if(btn(⬅️)) then cur_x-=3 end
	if(btn(➡️)) then cur_x+=3 end


	if(btn()==0) then check_snap() end

	if(btnp(🅾️)) then
		if(node_sel and node_fcs!=false) then
			create_cmd(active_plyr, node_sel, node_fcs)

			--hvrtxt('odr:'..alpha(node_sel)..alpha(node_fcs), cur_x, cur_y)
			node_sel=false
		else
			node_sel=node_fcs
		end
	end


	if(btnp(❎)) then
		if(node_sel==false) then
			view='cmds'
		else
			node_sel=false
		end
	end

	-- put in bounds?
end


function hdl_cmds()
	if(btnp(⬆️)) then cmd_fcs-=1 end
	if(btnp(⬇️)) then cmd_fcs+=1 end

	cmd_fcs = clamp(cmd_fcs, 1, #hero().cmds)

	if(btnp(🅾️)) then
		-- UI to cancel order
		if(cmd_sel!=false) then
			-- remove order
			del(hero().cmds, hero().cmds[cmd_sel])
			cmd_sel=false
		else
			cmd_sel=cmd_fcs
		end
	end

	if(btnp(❎)) then
		if(cmd_sel!=false) then
			cmd_sel=false
		else
			view='nodes'
		end
	end
end





function draw_cursor()
	local x,y=cur_x,cur_y
	local d=cur_ani.get()
	--if(cur_fcs==false) d=-1

	if(node_sel) then
		local sx,sy=pos(node_sel)
		quad(-8, function(dx,dy)
			spr(5,sx+dx,sy+dy,1,1,dx==0,dy==0)
		end)
	end

	quad(-8, function(dx,dy)
		spr(d,x+dx,y+dy,1,1,dx==0,dy==0)
	end)

end


function check_snap()
	node_fcs=false
	local close_node=rank_nodes(cur_x,cur_y)[1]
	local tx,ty=pos(close_node)
	--log(rank_nodes2(cur_x,cur_y))

	if(dist(cur_x,cur_y,tx,ty)<12) then
		node_fcs=close_node
		cur_x,cur_y=tx,ty
	end
end

--ui




function draw_reticle(x,y,w,h)
	local d=cur_ani.get()

	spr(d,x,y,1,1,false,false)
	spr(d,x+w,y,1,1,true,false)
	spr(d,x,y+h,1,1,false,true)
	spr(d,x+w,y+h,1,1,true,true)
end





--- HOVER TEXT ---

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
		if(h.o<0.1) then del(hvr_txt,h) end
	end
end

function draw_hvrtxt()
	for h in all(hvr_txt) do
		shadow_text(h.txt,h.x,h.y+h.o,h.c)
	end
end