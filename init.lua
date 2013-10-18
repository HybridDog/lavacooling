-------------------------------------------lavacooling-----------------------------------------------
local WATER = {"default:water_source", "default:water_flowing"}
local LAVA = {"default:lava_flowing","default:lava_source"}

local function coolnode(na, pos)
	minetest.add_node (pos, {name = na})
	minetest.sound_play("lavacooling", {pos = pos,	gain = 0.5,	max_hear_distance = 5})
	minetest.add_particlespawner(
		3, --amount
		0.1, --time
		{x=pos.x-0.2, y=pos.y-0.2, z=pos.z-0.2}, --minpos
		{x=pos.x+0.2, y=pos.y+0.2, z=pos.z+0.2}, --maxpos
		{x=-0, y=-0, z=-0}, --minvel
		{x=0, y=0, z=0}, --maxvel
		{x=-0.5,y=5,z=-0.5}, --minacc
		{x=0.5,y=5,z=0.5}, --maxacc
		0.1, --minexptime
		1, --maxexptime
		2, --minsize
		8, --maxsize
		false, --collisiondetection
		"smoke_puff.png" --texture
	)
	print("[lavacooling] "..na.." appeared at ("..pos.x..", "..pos.y..", "..pos.z..")")
end


--Change the old block

minetest.register_node(":lavacooling:obsidian", {})
minetest.register_abm ({
	nodenames = {"lavacooling:obsidian"},
	interval = 0,
	chance = 1,
	action = function (pos)
		minetest.add_node (pos, {name = "default:obsidian"})
	end,
})


--Nodes/Items

minetest.register_node("lavacooling:obsidian_brick", {
	description = "Obsidian Brick",
	tiles = {"lavacooling_obsidian_brick.png"},
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky=1,level=2},
})

minetest.register_node("lavacooling:basalt", {
	description = "Basalt",
	tiles = {"lavacooling_basalt.png","lavacooling_basalt.png","lavacooling_basalt_side.png",
			 "lavacooling_basalt_side.png","lavacooling_basalt_side.png^[transformR180","lavacooling_basalt_side.png"},
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky=3},
	drop = "default:cobble",
})


--tooldef("lavacooling", "obsidian", "Obsidian", 10, 0.5, 0.5, 0.5, 0.5)


--Crafts

minetest.register_craft({
	output = "lavacooling:obsidian_brick 4",
	recipe = {
		{"default:obsidian", "default:obsidian"},
		{"default:obsidian", "default:obsidian"},
	}
})


--ABMs

local default_ore_list = {
	{"stone_with_coal", 50},
	{"stone_with_iron", 200},
	{"stone_with_diamond", 500},
	{"stone_with_mese", 600},
}

local extrablocks_ore_list = {
	{"marble_ore", 50},
	{"lapis_lazuli_ore", 60},
	{"goldstone", 500},
	{"iringnite_ore", 600},
}

local function ret_ore(ore_list, mname)
	if mname == nil then
		mname = ""
	end
	for _,i in ipairs(ore_list) do
		if math.random(i[2]) == 1 then
			return mname..i[1]
		end
	end
	return false
end

local extrablocks_enabled = minetest.get_modpath("extrablocks")

local function ore()
	local default_ore = ret_ore(default_ore_list, "default:")
	if default_ore then
		return default_ore
	end
	if extrablocks_enabled then
		local extrablocks_ore = ret_ore(default_ore_list, "extrablocks:")
		if extrablocks_ore then
			return extrablocks_ore
		end
	end
	return "default:stone"
end


local function find_coolingnodes(coolingnodes, pos)
	for _, water in ipairs(coolingnodes) do
		for i=-1,1,2 do
			for _,p in ipairs({
				{x=pos.x+i, y=pos.y, z=pos.z},
				{x=pos.x, y=pos.y+i, z=pos.z},
				{x=pos.x, y=pos.y, z=pos.z+i}
			}) do
				if minetest.get_node(p).name == water then
					return true
				end
			end
		end
	end
	return false
end


local function lavacooling_abm(input, coolingnodes, output)
minetest.register_abm ({
	nodenames = {input},
	interval = 0,
	chance = 1,
	action = function (pos)
		if find_coolingnodes(coolingnodes, pos) then
			coolnode(output, pos)
		end
	end,
})
end

default.cool_lava_source = function()end
default.cool_lava_flowing = function()end

lavacooling_abm("default:lava_source", WATER, "default:obsidian")
minetest.register_abm ({
	nodenames = {"default:lava_flowing"},
	interval = 0,
	chance = 1,
	action = function (pos)
		if find_coolingnodes(WATER, pos) then
			if pos.y < -10+math.random(5) then
				coolnode("lavacooling:basalt", pos)
			else
				coolnode("default:cobble", pos)
			end

		end
	end,
})

minetest.register_abm ({
	nodenames = {"default:water_source"},
	interval = 0,
	chance = 1,
	action = function (pos)
		for _, lava in ipairs(LAVA) do
			if minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name == lava then
				coolnode(ore(), pos)
				return
			end
		end
	end,
})



if minetest.get_modpath("sumpf") then
lavacooling_abm("default:lava_source", {"sumpf:dirtywater_flowing", "sumpf:dirtywater_source"}, "default:obsidian")

local sw_ore_list = {
	{"sumpf:kohle", 37},
	{"sumpf:eisen", 50},
	{"default:mese", 200},
	{"default:obsidian", 250},
}

local function dirtyblocks(pos)
	local node_under = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
	if node_under == "sumpf:dirtywater_flowing" then
		return "default:dirt"
	end
	for i=-1,1,2 do
		if minetest.get_node({x=pos.x+i, y=pos.y, z=pos.z}).name == "sumpf:dirtywater_flowing"
		or minetest.get_node({x=pos.x, y=pos.y, z=pos.z+i}).name == "sumpf:dirtywater_flowing" then
			return "default:sand"
		end
	end
	if node_under == "sumpf:dirtywater_source" then
		local sw_ore = ret_ore(sw_ore_list)
		if sw_ore then
			return sw_ore
		end
		return "sumpf:junglestone"
	end
end

local function dirtyblocks2(pos)
	if minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "default:lava_flowing" then
		return "default:clay"
	end
	for i=-1,1,2 do
		if minetest.get_node({x=pos.x+i, y=pos.y, z=pos.z}).name == "default:lava_flowing" then
			return "sumpf:sumpf"
		end
		if minetest.get_node({x=pos.x, y=pos.y, z=pos.z+i}).name == "default:lava_flowing" then
			return "sumpf:peat"
		end
	end
end

local function dirtyblocks3(pos)
	if minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "default:lava_flowing" then
		return "default:gravel"
	end
end

minetest.register_abm ({
	nodenames = {"sumpf:dirtywater_flowing"},
	interval = 0,
	chance = 1,
	action = function (pos)
		local nam = dirtyblocks3(pos)
		if nam then
			coolnode(nam, pos)
		end
	end,
})
minetest.register_abm ({
	nodenames = {"sumpf:dirtywater_source"},
	interval = 0,
	chance = 1,
	action = function (pos)
		local nam = dirtyblocks2(pos)
		if nam then
			coolnode(nam, pos)
		end
	end,
})

minetest.register_abm ({
	nodenames = {"default:lava_flowing"},
	interval = 0,
	chance = 1,
	action = function (pos)
		local nam = dirtyblocks(pos)
		if nam then
			coolnode(nam, pos)
		end
	end,
})

end

print("[lavacooling] loaded")
