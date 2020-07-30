pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--graph tactics
--by:scott tolksdorf

--[[ TODO:

-- draw orders
-- update orders



]]


active_plyr=1
dev=true
troop_speed=0.005
fog=true
function cmd_speed(plyr)
	-- factor in cmd count here
	return 0.01
end
function grow_spd(plyr)
	return 0.005
end
function max_size(plyr)
	--based on number of node they control?
	return 5
end

function hero()
	return plyrs[active_plyr]
end





---------------


function _init()
	load_dummy()

	--init_mapgen()


	init_map()
	init_ui()
	init_game()



end

function _update()
	test()

	if(dev and btnp(6)) then
		poke(0x5f30,1)
		active_plyr=modu(active_plyr+1, #plyrs)
	end

	update_map()


	update_ui()
	update_game()
end

function _draw()
	cls()

	rect(0,0,127,127, 5)


	draw_map()
	draw_ui()
	draw_game()

	if(dev) then draw_logs() end
end









-- intro menu code below


--[[
function _update()
	if(dev) test()

	upt()

	update_orders()

	update_troops()
	update_nodes()
	update_scores()
	update_cur()
	update_hvrtxt()

end

]]--