-- Weapon shop configuration
local weaponShopConfig = {
    regularWeapons = {
        ["WEAPON_ASSAULTRIFLE"] = {price = 5800, category = "assault", id = "W-AR-001"},
        ["WEAPON_CARBINERIFLE"] = {price = 5200, category = "assault", id = "W-AR-002"},
        ["WEAPON_HEAVYSNIPER"] = {price = 15000, category = "sniper", id = "W-SN-001"},
        ["WEAPON_SMG"] = {price = 3500, category = "smg", id = "W-SMG-001"},
        ["WEAPON_PUMPSHOTGUN"] = {price = 2800, category = "shotgun", id = "W-SH-001"},
        ["WEAPON_MG"] = {price = 7500, category = "lmg", id = "W-LMG-001"},
        ["WEAPON_PISTOL"] = {price = 1200, category = "pistol", id = "W-PI-001"},
        ["WEAPON_KNIFE"] = {price = 500, category = "melee", id = "W-ME-001"}
    },
    
    premiumWeapons = {
        ["WEAPON_SPECIALCARBINE"] = {price = 9500, category = "assault", id = "W-AR-P01"},
        ["WEAPON_MARKSMANRIFLE"] = {price = 18000, category = "sniper", id = "W-SN-P01"},
        ["WEAPON_COMBATPDW"] = {price = 8500, category = "smg", id = "W-SMG-P01"},
        ["WEAPON_ASSAULTSHOTGUN"] = {price = 9500, category = "shotgun", id = "W-SH-P01"},
        ["WEAPON_COMBATMG"] = {price = 12000, category = "lmg", id = "W-LMG-P01"},
        ["WEAPON_APPISTOL"] = {price = 6500, category = "pistol", id = "W-PI-P01"},
        ["WEAPON_SWITCHBLADE"] = {price = 2500, category = "melee", id = "W-ME-P01"}
    },
    
    premiumPrices = {
        monthly = 499,
        quarterly = 1299,
        lifetime = 4999
    }
}


-- Get player license identifier
local function getPlayerLicense(source)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(id, 1, 8) == "license:" then
            return id
        end
    end
    return nil
end

-- Get player data from database
local function getPlayerData(source, callback)
    local license = getPlayerLicense(source)
    if not license then return callback(nil) end

    MySQL.Async.fetchAll('SELECT * FROM players WHERE identifier = @identifier', {
        ['@identifier'] = license
    }, function(result)
        if not result or #result == 0 then
            callback(nil)
            return
        end

        local player = result[1]

        -- Get player's owned weapons
        MySQL.Async.fetchAll('SELECT weapon_name FROM player_weapons WHERE player_id = @player_id', {
            ['@player_id'] = player.id
        }, function(weaponsResult)
            local ownedWeapons = {}
            if weaponsResult and #weaponsResult > 0 then
                for _, weapon in ipairs(weaponsResult) do
                    ownedWeapons[weapon.weapon_name] = true
                end
            end

            player.ownedWeapons = 
            print("[DEBUG] Raw is_premium:", player.is_premium, "Type:", type(player.is_premium))
            print("[DEBUG] Evaluated isPremium:", tonumber(player.is_premium) == 1)
            callback(player)
        end)
    end)
end


-- Update player money in database
local function updatePlayerMoney(source, amount)
    local license = getPlayerLicense(source)
    if not license then return false end
    
    return MySQL.Sync.execute('UPDATE players SET money = @money WHERE identifier = @identifier', {
        ['@money'] = amount,
        ['@identifier'] = license
    }) > 0
end

-- Add weapon to player
local function addPlayerWeapon(source, weaponName)
    local license = getPlayerLicense(source)
    if not license then return false end
    
    local playerId = MySQL.Sync.fetchScalar('SELECT id FROM players WHERE identifier = @identifier', {
        ['@identifier'] = license
    })
    
    if not playerId then return false end
    
    local defaultAmmo = 150
    
    local existingWeapon = MySQL.Sync.fetchAll('SELECT * FROM player_weapons WHERE player_id = @player_id AND weapon_name = @weapon_name', {
        ['@player_id'] = playerId,
        ['@weapon_name'] = weaponName
    })
    
    if existingWeapon and #existingWeapon > 0 then
        MySQL.Sync.execute('UPDATE player_weapons SET ammo = ammo + @ammo WHERE id = @id', {
            ['@ammo'] = defaultAmmo,
            ['@id'] = existingWeapon[1].id
        })
    else
        MySQL.Sync.execute('INSERT INTO player_weapons (player_id, weapon_name, ammo) VALUES (@player_id, @weapon_name, @ammo)', {
            ['@player_id'] = playerId,
            ['@weapon_name'] = weaponName,
            ['@ammo'] = defaultAmmo
        })
    end
    
    return true
end

-- Handle weapon purchase
RegisterNetEvent('weaponshop:buyWeapon')
AddEventHandler('weaponshop:buyWeapon', function(weaponId)
    local src = source
    
    -- Find weapon in config
    local weaponName, weaponData, isPremiumWeapon
    for name, data in pairs(weaponShopConfig.regularWeapons) do
        if data.id == weaponId then
            weaponName = name
            weaponData = data
            isPremiumWeapon = false
            break
        end
    end
    
    if not weaponName then
        for name, data in pairs(weaponShopConfig.premiumWeapons) do
            if data.id == weaponId then
                weaponName = name
                weaponData = data
                isPremiumWeapon = true
                break
            end
        end
    end
    
    if not weaponData then
        TriggerClientEvent('chat:addMessage', src, {args = {"Weapon Shop", "Invalid weapon selected"}})
        return
    end
    
    getPlayerData(src, function(player)
        if not player then
            TriggerClientEvent('chat:addMessage', src, {args = {"Weapon Shop", "Failed to load your player data"}})
            return
        end
        
        -- Check if player already owns this weapon
        if player.ownedWeapons[weaponName] then
            TriggerClientEvent('chat:addMessage', src, {args = {"Weapon Shop", "You already own this weapon!"}})
            TriggerClientEvent('weaponshop:updatePlayerData', src, player.money, player.is_premium, player.faction, player.ownedWeapons)
            return
        end
        
        if isPremiumWeapon and player.is_premium ~= 1 then
            TriggerClientEvent('chat:addMessage', src, {args = {"Weapon Shop", "You need premium membership to purchase this weapon"}})
            return
        end
        
        if player.money < weaponData.price then
            TriggerClientEvent('chat:addMessage', src, {args = {"Weapon Shop", "You don't have enough money"}})
            return
        end
        
        local newMoney = player.money - weaponData.price
        if updatePlayerMoney(src, newMoney) and addPlayerWeapon(src, weaponName) then
            -- Update owned weapons list
            player.ownedWeapons[weaponName] = true
            
            TriggerClientEvent('weaponshop:updatePlayerData', src, newMoney, player.is_premium == 1, player.faction, player.ownedWeapons)
            
            local playerPed = GetPlayerPed(src)
            GiveWeaponToPed(playerPed, GetHashKey(weaponName), 150, false, true)
            
            TriggerClientEvent('chat:addMessage', src, {
                args = {"Weapon Shop", "You purchased a " .. weaponName .. " for $" .. weaponData.price}
            })
        else
            TriggerClientEvent('chat:addMessage', src, {args = {"Weapon Shop", "Transaction failed"}})
        end
    end)
end)

-- Handle premium purchase
RegisterNetEvent('weaponshop:buyPremium')
AddEventHandler('weaponshop:buyPremium', function(premiumType)
    local src = source
    local price = weaponShopConfig.premiumPrices[premiumType]
    
    if not price then
        TriggerClientEvent('chat:addMessage', src, {args = {"Weapon Shop", "Invalid premium type"}})
        return
    end
    
    getPlayerData(src, function(player)
        print("[DEBUG] is_premium from DB:", player.is_premium)
        if not player then
            TriggerClientEvent('chat:addMessage', src, {args = {"Weapon Shop", "Failed to load your player data"}})
            return
        end
        
        if player.is_premium == 1 then
            TriggerClientEvent('chat:addMessage', src, {args = {"Weapon Shop", "You are already a premium member"}})
            return
        end
        
        if player.money < price then
            TriggerClientEvent('chat:addMessage', src, {args = {"Weapon Shop", "You don't have enough money"}})
            return
        end
        
        local newMoney = player.money - price
        MySQL.Async.execute('UPDATE players SET money = @money, is_premium = 1 WHERE identifier = @identifier', {
            ['@money'] = newMoney,
            ['@identifier'] = player.identifier
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('weaponshop:updatePlayerData', src, newMoney, true, player.faction, player.ownedWeapons)
                TriggerClientEvent('chat:addMessage', src, {
                    args = {"Weapon Shop", "Thank you for purchasing premium membership!"}
                })
            else
                TriggerClientEvent('chat:addMessage', src, {args = {"Weapon Shop", "Transaction failed"}})
            end
        end)
    end)
end)

-- Provide player data when opening shop
RegisterNetEvent('weaponshop:getPlayerData')
AddEventHandler('weaponshop:getPlayerData', function()
    local src = source
    getPlayerData(src, function(player)
        print("[DEBUG] weaponshop:getPlayerData triggered by", src)
        if player then
            TriggerClientEvent('weaponshop:updatePlayerData', src, player.money, player.is_premium, player.faction, player.ownedWeapons)
        else
            TriggerClientEvent('chat:addMessage', src, {args = {"Weapon Shop", "Failed to load your player data"}})
            TriggerClientEvent('weaponshop:closeShop', src)
        end
    end)
end)

-- Define the function FIRST
local function giveWeaponsFromDatabase(source)
    local license = getPlayerLicense(source)
    if not license then
        print("[WEAPON SYNC] No license found for source", source)
        return
    end

    MySQL.Async.fetchAll('SELECT id FROM players WHERE identifier = @identifier', {
        ['@identifier'] = license
    }, function(result)
        if result and result[1] then
            local playerId = result[1].id

            MySQL.Async.fetchAll('SELECT weapon_name, ammo FROM player_weapons WHERE player_id = @player_id', {
                ['@player_id'] = playerId
            }, function(weapons)
                if weapons and #weapons > 0 then
local weaponData = {}
for _, weapon in ipairs(weapons) do
    print("[WEAPON SYNC] Queueing", weapon.weapon_name, "with", weapon.ammo, "ammo")
    table.insert(weaponData, {
        name = weapon.weapon_name,
        ammo = weapon.ammo
    })
end

TriggerClientEvent('weaponshop:giveWeaponsToPlayer', source, weaponData)

                else
                    print("[WEAPON SYNC] No weapons found for player_id", playerId)
                end
            end)
        else
            print("[WEAPON SYNC] No player found in DB for license", license)
        end
    end)
end

RegisterNetEvent('weaponshop:requestWeapons')
AddEventHandler('weaponshop:requestWeapons', function()
    local src = source
    giveWeaponsFromDatabase(src)
end)

