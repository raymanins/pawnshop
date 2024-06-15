local config = Config -- Reference the Config table

lib.callback.register('qb-pawnshop:server:sellPawnItems', function(source, itemName, itemAmount)
    local Player = exports.qbx_core:GetPlayer(source)
    local itemConfig = nil

    for _, item in ipairs(config.Items) do
        if item.name == itemName then
            itemConfig = item
            break
        end
    end

    if not itemConfig then
        exports.qbx_core:Notify(source, 'Item not found in config.', 'error')
        return
    end

    local itemPrice = math.random(itemConfig.minPrice, itemConfig.maxPrice)
    local totalPrice = tonumber(itemAmount) * itemPrice
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local isNearPawnshop = false

    for _, value in pairs(config.PawnLocation) do
        local dist = #(playerCoords - value.coords)
        if dist < 5 then
            isNearPawnshop = true
            break
        end
    end
    if Player.Functions.RemoveItem(itemName, tonumber(itemAmount)) then
        if config.BankMoney then
            Player.Functions.AddMoney('bank', totalPrice)
        else
            Player.Functions.AddMoney('cash', totalPrice)
        end
        exports.qbx_core:Notify(source, Lang:t('success.sold', { value = tonumber(itemAmount), value2 = exports.ox_inventory:Items()[itemName].label, value3 = totalPrice }), 'success')
        TriggerClientEvent('inventory:client:ItemBox', source, exports.ox_inventory:Items()[itemName], 'remove')
    else
        exports.qbx_core:Notify(source, Lang:t('error.no_items'), 'error')
    end
    TriggerClientEvent('qb-pawnshop:client:openMenu', source)
end)

lib.callback.register('qb-pawnshop:server:meltItemRemove', function(source, itemName, itemAmount, item)
    local Player = exports.qbx_core:GetPlayer(source)
    if Player.Functions.RemoveItem(itemName, itemAmount) then
        TriggerClientEvent('inventory:client:ItemBox', source, exports.ox_inventory:Items()[itemName], 'remove')
        local meltTime = tonumber(itemAmount) * item.time
        TriggerClientEvent('qb-pawnshop:client:startMelting', source, item, itemAmount, (meltTime * 60000 / 1000))
        exports.qbx_core:Notify(source, Lang:t('info.melt_wait', { value = meltTime }), 'primary')
    else
        exports.qbx_core:Notify(source, Lang:t('error.no_items'), 'error')
    end
end)

lib.callback.register('qb-pawnshop:server:pickupMelted', function(source, item)
    local Player = exports.qbx_core:GetPlayer(source)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local isNearPawnshop = false

    for _, value in pairs(config.PawnLocation) do
        local dist = #(playerCoords - value.coords)
        if dist < 5 then
            isNearPawnshop = true
            break
        end
    end

    for _, v in pairs(item.items) do
        local meltedAmount = v.amount
        for _, m in pairs(v.item.reward) do
            local rewardAmount = m.amount
            if Player.Functions.AddItem(m.item, meltedAmount * rewardAmount) then
                TriggerClientEvent('inventory:client:ItemBox', source, exports.ox_inventory:Items()[m.item], 'add')
                exports.qbx_core:Notify(source, Lang:t('success.items_received', { value = meltedAmount * rewardAmount, value2 = exports.ox_inventory:Items()[m.item].label }), 'success')
            else
                TriggerClientEvent('qb-pawnshop:client:openMenu', source)
                return
            end
        end
    end
    TriggerClientEvent('qb-pawnshop:client:resetPickup', source)
    TriggerClientEvent('qb-pawnshop:client:openMenu', source)
end)

lib.callback.register('qb-pawnshop:server:getInv', function(source)
    local Player = exports.qbx_core:GetPlayer(source)
    local inventory = Player.PlayerData.items
    return inventory
end)
