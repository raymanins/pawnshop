Config = {}

Config.PedModel = 's_m_m_highsec_01' -- The model of the ped
Config.PedCoords = vector3(173.2212, -1316.8187, 29.3472) -- Coordinates for the ped
Config.PedHeading = 240.9162 -- Heading of the ped

Config.Items = {
    { name = 'goldchain', minPrice = 1, maxPrice = 5 },
    { name = 'rolex', minPrice = 5, maxPrice = 10 }
}

Config.PawnLocation = {
    { coords = vector3(127.0, -1282.0, 29.3) } -- Add more pawn locations if needed
}

Config.BankMoney = false -- If true, money will be added to the bank account

-- Blip settings
Config.Blip = {
    coords = vector3(173.2212, -1316.8187, 29.3472), -- Same as PedCoords or different as needed
    sprite = 605, -- Blip icon
    color = 5, -- Blip color
    scale = 0.8, -- Blip scale
    text = 'Pawn Shop' -- Blip name
}
