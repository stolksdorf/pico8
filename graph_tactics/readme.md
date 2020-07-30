# graph tatics


## Todo
- Draw orders onto map
	- highlight order if focused
- Make a focused node UI
	- show name, id, size, and tick
- Improve cursor
	- draw_reticle(x,y,w,h) this will track animation
	- draw_cursor() looks at view and focus states to pick the right x,y
- add a player select
	- Have to update change view to cycle
	- Clean up the cursor data structure
	- changes a `main_plyr` val

- Add cancelling of orders






Controls

sqr - confirm/select node/order
X - switch views/cancel selection



### Map gen
- have separate regions, cluster nodes within regions
- have touching regions share a link between their closest nodes





## Data Structures


settings : {
	troop_speed
	fog_of_war
	recruit_speed
	order_speed
	order_delta_fn: (order_count)=>speed_mod
}

ui_state : {
	view : 'orders'/'nodes'

	cur : {x,y}

	node_focus: false/id
	node_select: false/id,
	order_select: false/id
	order_focus: false/id


	focus : false / node_id (if(view is nodes) / order_id (if(view is orders)

}



# Nodes
[{
	x,y
	name,
	team : 0,
	troops/size

	tick: 100 //Starts at 100, decreases at 0 adds troop to node. Resets only if(is_safe()
	links: [link_id]
	nhbrs : [node_ids...] // maybe make this into a util
}]


### troop
[{
	link: link_id
	team: 3

	percentage/dist/ratio (along the link length)
	dir : 1 or -1


	tick : 100 //tied to troop_speed
}]


### Links
[{
	from, to

	length : // in pixels, pre-calculated on map-gen


}]


### players

[{

	orders : [{
		link : link_id ??
		tick : 100 // starts at 100 and decreases, at 0 order fires and resets
	}],
	colors : 2,
	// nodes  : [node_id, ...,] (this should be a look up)

}]


###