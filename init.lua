-------------------------------------------lavacooling-----------------------------------------------

--Nodes/Items

local function lavacooling_node(name, desc)
minetest.register_node("lavacooling:"..name, {
	description = desc,
	tiles = {"lavacooling_"..name..".png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
})
end

lavacooling_node("obsidian", "Obsidian")
lavacooling_node("obsidian_brick", "Obsidian Brick")

--tooldef("lavacooling", "obsidian", "Obsidian", 10, 0.5, 0.5, 0.5, 0.5)


--Crafts

minetest.register_craft({
	output = "lavacooling:obsidian_brick 4",
	recipe = {
		{"lavacooling:obsidian", "lavacooling:obsidian"},
		{"lavacooling:obsidian", "lavacooling:obsidian"},
	}
})


--ABMs

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
				or minetest.env: get_node({x=pos.x, y=pos.y, z=pos.z+i}).name == water
				then
				minetest.env: add_node (pos, {name = output})
				minetest.sound_play("lavacooling", {pos = pos,	gain = 1.0,	max_hear_distance = 5})
				end
			end
		end
	end,
})
end

lavacooling_abm("default:lava_source", WATER, "lavacooling:obsidian")
lavacooling_abm("default:lava_flowing", WATER, "default:cobble")

minetest.register_abm ({
	nodenames = {"default:water_source"},
	interval = 0,
	chance = 1,
	action = function (pos)
		for _, lava in ipairs(LAVA) do
			if minetest.env: get_node({x=pos.x, y=pos.y+1, z=pos.z}).name == lava then
				minetest.env: add_node (pos, {name = "default:stone"})
				minetest.sound_play("lavacooling", {pos = pos,	gain = 1.0,	max_hear_distance = 5})
			end
		end
	end,
})

--[[
minetest.register_abm ({
	nodenames = {"default:lava_flowing"},
	interval = 5,
	chance = 60,
	action = function (pos)
		minetest.env: add_node (pos, {name = "lavacooling:obsidian"})
	end,
})]]
