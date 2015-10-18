local load_time_start = os.clock()
-------------------------------------------lavacooling-----------------------------------------------
local WATER = {"default:water_source", "default:water_flowing"}
local LAVA = {"default:lava_flowing","default:lava_source"}

local function coolnode(na, pos)
	minetest.add_node (pos, {name = na})
	minetest.sound_play("default_cool_lava", {pos = pos,  gain = 0.25})
	minetest.add_particlespawner({
		amount = 3,
		time = 0.1,
		minpos = {x=pos.x-0.2, y=pos.y-0.2, z=pos.z-0.2},
		maxpos = {x=pos.x+0.2, y=pos.y+0.2, z=pos.z+0.2},
		minacc = {x=-0.5,y=5,z=-0.5},
		maxacc = {x=0.5,y=5,z=0.5},
		minexptime = 0.1,
		minsize = 2,
		maxsize = 8,
		texture = "smoke_puff.png"
	})
	print("[lavacooling] "..na.." appeared at ("..pos.x..", "..pos.y..", "..pos.z..")")
end

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


--Nodes/Items

minetest.register_node(":default:basalt", {
	description = "basalt",
	tiles = {"lavacooling_basalt.png","lavacooling_basalt.png","lavacooling_basalt_side.png",
			 "lavacooling_basalt_side.png","lavacooling_basalt_side.png^[transformR180","lavacooling_basalt_side.png"},
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky=3},
})

if not minetest.registered_nodes["default:obsidianbrick"] then
	local tmp = deepcopy(minetest.registered_nodes["default:obsidian"])
	tmp.description = tmp.description.." brick"
	tmp.tiles = {"lavacooling_obsidian_brick.png"}

	minetest.register_node(":default:obsidianbrick", tmp)
--tooldef("lavacooling", "obsidian", "Obsidian", 10, 0.5, 0.5, 0.5, 0.5)


--Crafts

	minetest.register_craft({
		output = "default:obsidianbrick 4",
		recipe = {
			{"default:obsidian", "default:obsidian"},
			{"default:obsidian", "default:obsidian"},
		}
	})
end


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
		local extrablocks_ore = ret_ore(extrablocks_ore_list, "extrablocks:")
		if extrablocks_ore then
			return extrablocks_ore
		end
	end
	return "default:stone"
end


local function find_coolingnodes(coolingnodes, pos)
	for _, water in pairs(coolingnodes) do
		for i=-1,1,2 do
			for _,p in pairs({
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

local function cool_wf_vm(pos)
	local t1 = os.clock()
	local minp = vector.subtract(pos, 10)
	local maxp = vector.add(pos, 10)
	local manip = minetest.get_voxel_manip()
	local emerged_pos1, emerged_pos2 = manip:read_from_map(minp, maxp)
	local area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
	local nodes = manip:get_data()

	local basalt = minetest.get_content_id("default:basalt")
	local cobble = minetest.get_content_id("default:cobble")
	local lava = minetest.get_content_id("default:lava_flowing")

	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				local p = {x=x, y=y, z=z}
				local p_p = area:indexp(p)
				if nodes[p_p] == lava then
					if find_coolingnodes(WATER, p) then
						if y < -10+math.random(5) then
							nodes[p_p] = basalt
						else
							nodes[p_p] = cobble
						end
					end
				end
			end
		end
	end


	manip:set_data(nodes)
	manip:write_to_map()
	print(string.format("[lavacooling] cooled at ("..pos.x.."|"..pos.y.."|"..pos.z..") after ca. %.2fs", os.clock() - t1))
	local t1 = os.clock()
	manip:update_map()
	print(string.format("[lavacooling] map updated after ca. %.2fs", os.clock() - t1))
end

local del1 = 0
local count = 0

minetest.register_abm ({
	nodenames = {"default:lava_flowing"},
	interval = 0,
	chance = 1,
	action = function (pos)
		local del2 = tonumber(os.clock())
		if del2-del1 < 0.1
		and count > 10 then
			cool_wf_vm(pos)
			count = 0
		elseif find_coolingnodes(WATER, pos) then
			if pos.y < -10+math.random(5) then
				coolnode("default:basalt", pos)
			else
				coolnode("default:cobble", pos)
			end
			if del2-del1 < 0.1 then
				count = count+1
			end
		end
		del1 = del2
	end,
})

minetest.register_abm ({
	nodenames = {"default:water_source"},
	interval = 0,
	chance = 1,
	action = function (pos)
		for _, lava in pairs(LAVA) do
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


-- legacy
--Change the old nodes

for _,node in pairs({
	{"lavacooling:obsidian", "default:obsidian"},
	{"lavacooling:obsidian_brick", "default:obsidianbrick"},
	{"default:obsidian_brick", "default:obsidianbrick"},
	{"lavacooling:basalt", "default:basalt"},
}) do
	local input = node[1]
	local output = node[2]
	minetest.register_node(":"..input, {})
	minetest.register_abm ({
		nodenames = {input},
		interval = 0,
		chance = 1,
		action = function (pos)
			minetest.add_node (pos, {name = output})
			print("[lavacooling] "..input.." changed to "..output.." at ("..pos.x..", "..pos.y..", "..pos.z..")")
		end,
	})
end


local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[lavacooling] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
