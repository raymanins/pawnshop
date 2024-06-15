local ox_target = exports.ox_target
local ox_inventory = exports.ox_inventory

CreateThread(function()
    -- Load the ped model
    RequestModel(Config.PedModel)
    while not HasModelLoaded(Config.PedModel) do
        Wait(1)
    end

    -- Create the ped
    local ped = CreatePed(4, Config.PedModel, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 1, Config.PedHeading, false, true)
    SetEntityAsMissionEntity(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)

    -- Add target interaction
    ox_target:addLocalEntity(ped, {
        {
            label = 'Sell Items',
            icon = 'fa-solid fa-dollar-sign',
            onSelect = function()
                SellItems()
            end
        }
    })

    -- Add blip to the map
    local blip = AddBlipForCoord(Config.Blip.coords.x, Config.Blip.coords.y, Config.Blip.coords.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.text)
    EndTextCommandSetBlipName(blip)
end)

function SellItems()
    local sellableItems = {}

    for _, configItem in ipairs(Config.Items) do
        local itemCount = ox_inventory:Search('count', configItem.name)
        if itemCount > 0 then
            table.insert(sellableItems, { name = configItem.name, count = itemCount, minPrice = configItem.minPrice, maxPrice = configItem.maxPrice })
        end
    end

    if #sellableItems == 0 then
        lib.notify({title = 'Pawn Shop', description = 'You have no items to sell!', type = 'error'})
        return
    end

    local options = {}
    for _, item in ipairs(sellableItems) do
        local itemLabel = exports.ox_inventory:Items()[item.name].label
        local itemImage = 'nui://ox_inventory/web/images/' .. item.name .. '.png'
        local itemPrice = math.random(item.minPrice, item.maxPrice) -- Calculate a random price within the range
        table.insert(options, {
            title = itemLabel,
            description = 'Sell for a random price between ' .. item.minPrice .. ' and ' .. item.maxPrice,
            icon = itemImage,
            onSelect = function()
                lib.callback('qb-pawnshop:server:sellAllPawnItems', false, function(success)
                    if success then
                        lib.notify({title = 'Pawn Shop', description = 'Items sold successfully!', type = 'success'})
                    else
                        lib.notify({title = 'Pawn Shop', description = 'Error selling items', type = 'error'})
                    end
                end, sellableItems)
            end
        })
    end

    lib.registerContext({
        id = 'pawnshop_sell_menu',
        title = 'Sell Items',
        options = options
    })
    lib.showContext('pawnshop_sell_menu')
end
