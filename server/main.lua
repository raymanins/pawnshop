local config = Config -- Reference the Config table

lib.callback.register('qb-pawnshop:server:sellAllPawnItems', function(source, items)
    local Player = exports.qbx_core:GetPlayer(source)
    local totalPrice = 0

    for _, item in ipairs(items) do
        local itemConfig = nil
        for _, configItem in ipairs(config.Items) do
            if configItem.name == item.name then
                itemConfig = configItem
                break
            end
        end

        if itemConfig then
            if Player.Functions.RemoveItem(item.name, item.count) then
                local itemPrice = math.random(itemConfig.minPrice, itemConfig.maxPrice) * item.count
                totalPrice = totalPrice + itemPrice
                TriggerClientEvent('inventory:client:ItemBox', source, exports.ox_inventory:Items()[item.name], 'remove')
            else
                exports.qbx_core:Notify(source, 'You do not have enough items to sell.', 'error')
                return false
            end
        else
            exports.qbx_core:Notify(source, 'Item configuration not found.', 'error')
            return false
        end
    end

    if config.BankMoney then
        Player.Functions.AddMoney('bank', totalPrice)
    else
        Player.Functions.AddMoney('cash', totalPrice)
    end

    exports.qbx_core:Notify(source, 'Items sold for $' .. totalPrice, 'success')
    return true
end)
