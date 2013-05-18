-------------------------------------------lavacooling-----------------------------------------------
local WATER = {"default:water_source", "default:water_flowing"}
local LAVA = {"default:lava_flowing","default:lava_source"}

--Change the old block

minetest.register_node(":lavacooling:obsidian", {})
minetest.register_abm ({
	nodenames = {"lavacooling:obsidian"},
	interval = 0,
	chance = 1,
	action = function (pos)
		minetest.env: add_node (pos, {name = "default:obsidian"})
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
	tiles = {"lavacooling_basalt.png","lavacooling_basalt.png","lavacooling_basalt_side.png"},
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

local function ore()
	if math.random(50) == 1 then return "default:stone_with_coal" end
	if math.random(200) == 1 then return "default:stone_with_iron" end
	if math.random(500) == 1 then return "default:stone_with_diamond" end
	if math.random(600) == 1 then return "default:stone_with_mese" end
	return "default:stone"
end

local function lavacooling_abm(input, coolingnodes, output)
minetest.register_abm ({
	nodenames = {input},
	interval = 0,
	chance = 1,
	action = function (pos)
		for _, water in ipairs(coolingnodes) do
			for i=-1,1,2 do
				if minetest.env: get_node({x=pos.x+i, y=pos.y, z=pos.z}).name == water
				or minetest.env: get_node({x=pos.x, y=pos.y+i, z=pos.z}).name == water
				or minetest.env: get_node({x=pos.x, y=pos.y, z=pos.z+i}).name == water then
					minetest.env: add_node (pos, {name = output})
					minetest.sound_play("lavacooling", {pos = pos,	gain = 0.5,	max_hear_distance = 5})
					return
				end
			end
		end
	end,
})
end

default.cool_lava_source = function()end
default.cool_lava_flowing = function()end

lavacooling_abm("default:lava_source", WATER, "default:obsidian")
lavacooling_abm("default:lava_flowing", WATER, "lavacooling:basalt")

minetest.register_abm ({
	nodenames = {"default:water_source"},
	interval = 0,
	chance = 1,
	action = function (pos)
		for _, lava in ipairs(LAVA) do
			if minetest.env: get_node({x=pos.x, y=pos.y+1, z=pos.z}).name == lava then
				minetest.env: add_node (pos, {name = ore()})
				minetest.sound_play("lavacooling", {pos = pos,	gain = 0.5,	max_hear_distance = 5})
				return
			end
		end
	end,
})

if minetest.get_modpath("sumpf") then
lavacooling_abm("default:lava_source", {"sumpf:dirtywater_flowing", "sumpf:dirtywater_source"}, "default:obsidian")

local function dirtyblocks(pos)
	if minetest.env: get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "sumpf:dirtywater_flowing" then
		return "default:dirt"
	end
	for i=-1,1,2 do
		if minetest.env: get_node({x=pos.x+i, y=pos.y, z=pos.z}).name == "sumpf:dirtywater_flowing"
		or minetest.env: get_node({x=pos.x, y=pos.y, z=pos.z+i}).name == "sumpf:dirtywater_flowing"
			then return "default:sand"
		end
	end
	if minetest.env: get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "sumpf:dirtywater_source" then
		if math.random(37) == 1 then return "sumpf:kohle" end
		if math.random(50) == 1 then return "sumpf:eisen" end
		if math.random(200) == 1 then return "default:mese" end
		if math.random(250) == 1 then return "default:obsidian" end
		return "sumpf:junglestone"
	end
end

local function dirtyblocks2(pos)
	if minetest.env: get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "default:lava_flowing" then
		return "default:clay"
	end
	for i=-1,1,2 do
		if minetest.env: get_node({x=pos.x+i, y=pos.y, z=pos.z}).name == "default:lava_flowing"
			then return "sumpf:sumpf"
		end
		if minetest.env: get_node({x=pos.x, y=pos.y, z=pos.z+i}).name == "default:lava_flowing"
			then return "sumpf:peat"
		end
	end
end

local function dirtyblocks3(pos)
	if minetest.env: get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "default:lava_flowing" then
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
			minetest.env: add_node (pos, {name = nam})
			minetest.sound_play("lavacooling", {pos = pos,	gain = 0.5,	max_hear_distance = 5})
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
			minetest.env: add_node (pos, {name = nam})
			minetest.sound_play("lavacooling", {pos = pos,	gain = 0.5,	max_hear_distance = 5})
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
			minetest.env: add_node (pos, {name = nam})
			minetest.sound_play("lavacooling", {pos = pos,	gain = 0.5,	max_hear_distance = 5})
		end
	end,
})

end
