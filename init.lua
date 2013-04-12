-------------------------------------------lavacooling-----------------------------------------------

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
	groups = {cracky=1,level=2},
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
					minetest.sound_play("lavacooling", {pos = pos,	gain = 1.0,	max_hear_distance = 5})
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
				minetest.env: add_node (pos, {name = "default:stone"})
				minetest.sound_play("lavacooling", {pos = pos,	gain = 1.0,	max_hear_distance = 5})
				return
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
		minetest.env: add_node (pos, {name = "default:obsidian"})
	end,
})]]
