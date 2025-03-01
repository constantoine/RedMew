local ob = require 'map_gen.maps.crash_site.outpost_builder'
local Token = require 'utils.token'

local loot = {
    {weight = 5},
    {stack = {name = 'coin', count = 250, distance_factor = 1 / 20}, weight = 5},
    {stack = {name = 'copper-ore', count = 2400}, weight = 2},
    {stack = {name = 'copper-cable', count = 1500, distance_factor = 1 / 2}, weight = 2},
    {stack = {name = 'copper-plate', count = 1000, distance_factor = 1 / 5}, weight = 8},
    {stack = {name = 'low-density-structure', count = 30, distance_factor = 1 / 20}, weight = 1}
}

local weights = ob.prepare_weighted_loot(loot)

local loot_callback =
    Token.register(
    function(chest)
        ob.do_random_loot(chest, weights, loot)
    end
)

local factory = {
    callback = ob.magic_item_crafting_callback,
    data = {
        furnace_item = {name = 'copper-ore', count = 100},
        output = {min_rate = 2.5 / 60, distance_factor = 2.5 / 60 / 512, item = 'copper-plate'}
    }
}

local factory_b = {
    callback = ob.magic_item_crafting_callback,
    data = {
        recipe = 'low-density-structure',
        output = {min_rate = 0.35 / 60, distance_factor = 0.35 / 60 / 512, item = 'low-density-structure'}
    }
}

local market = {
    callback = ob.market_set_items_callback,
    data = {
        market_name = 'Big Copper Plate Factory',
        upgrade_rate = 0.5,
        upgrade_base_cost = 250,
        upgrade_cost_base = 2,
        {
            name = 'copper-cable',
            price = 0.12,
            distance_factor = 0.06 / 512,
            min_price = 0.012
        },
        {
            name = 'copper-plate',
            price = 0.3,
            distance_factor = 0.15 / 512,
            min_price = 0.03
        },
        {
            name = 'low-density-structure',
            price = 25,
            distance_factor = 12.5 / 512,
            min_price = 2.5
        }
    }
}

local base_factory = require 'map_gen.maps.crash_site.outpost_data.medium_furnace'
local base_factory2 = require 'map_gen.maps.crash_site.outpost_data.big_factory'

local level2 = ob.extend_1_way(base_factory[1], {loot = {callback = loot_callback}})
local level3 =
    ob.extend_1_way(
    base_factory[2],
    {
        factory = factory,
        fallback = level2
    }
)

local level3b =
    ob.extend_1_way(
    base_factory2[2],
    {
        factory = factory_b,
        fallback = level2,
        max_count = 1
    }
)

local level4 =
    ob.extend_1_way(
    base_factory[3],
    {
        market = market,
        fallback = level3b
    }
)
return {
    settings = {
        blocks = 9,
        variance = 3,
        min_step = 2,
        max_level = 3
    },
    walls = {
        require 'map_gen.maps.crash_site.outpost_data.heavy_gun_turrets'
    },
    bases = {
        {level2, level3},
        {level4}
    }
}
