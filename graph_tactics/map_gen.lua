--map_gen

function init_mapgen()
	dev_map()

end


function dev_map()
	local _info={
-- x y team size
		{56,16,0,0},
		{82,32,0,0},
		{40,99,0,0},
		{30,80,0,0},
		{55,40,0,0},
		{80,90,0,0}
	}
	local _links={
		{1,2},
		{1,5},
		{2,5},
		{2,6},
		{6,3},
		{3,4},
		{4,5}
	}



	for x in pairs(_info) do
		i=_info[x]
		nodes[x]={
			x=i[1],
			y=i[2],
			team=i[3] or 0,
			size=i[4] or 0,
			prox={}
		}
	end


	for i in pairs(_links) do
		local l=_links[i]
		local a=l[1]
		local b=l[2]

		add(nodes[a].prox,b)
		add(nodes[b].prox,a)
		links[i]={
			a=a,b=b,
			dist=node_dist(a,b)
		}
	end
end