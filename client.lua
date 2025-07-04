local isShopOpen = false

-- Key control (F6 to toggle)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 167) then -- F6 key
            if isShopOpen then
                CloseWeaponShop()
            else
                OpenWeaponShop()
            end
        end
        
        -- ESC key close
        if isShopOpen and IsControlJustReleased(0, 322) then
            CloseWeaponShop()
        end
    end
end)

function OpenWeaponShop()
    if isShopOpen then return end
    isShopOpen = true
    
    -- Get player data
    TriggerServerEvent('weaponshop:getPlayerData')
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openShop",
        show = true
    })
end

function CloseWeaponShop()
    if not isShopOpen then return end
    isShopOpen = false
    
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "closeShop",
        show = false
    })
end

-- NUI callbacks
RegisterNUICallback('buyWeapon', function(data, cb)
    TriggerServerEvent('weaponshop:buyWeapon', data.weaponId)
    cb({})
end)

RegisterNUICallback('buyPremium', function(data, cb)
    TriggerServerEvent('weaponshop:buyPremium', data.premiumType)
    cb({})
end)

RegisterNUICallback('closeShop', function(data, cb)
    CloseWeaponShop()
    cb({})
end)

-- Update player data
RegisterNetEvent('weaponshop:updatePlayerData')
AddEventHandler('weaponshop:updatePlayerData', function(money, isPremium, ownedWeapons)
    print("[DEBUG] Received from server:", money, isPremium) -- ADD THIS
    SendNUIMessage({
        type = "updatePlayerData",
        playerMoney = money,
        isPremium = isPremium,
        ownedWeapons = ownedWeapons
    })
    
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        CloseWeaponShop()
    end
end)

RegisterNetEvent('weaponshop:giveWeaponsToPlayer')
AddEventHandler('weaponshop:giveWeaponsToPlayer', function(weapons)
    print("[CLIENT] Received weapon list:", json.encode(weapons))
    local ped = PlayerPedId()
    for _, weapon in ipairs(weapons) do
        print("[CLIENT] Giving weapon:", weapon.name, "Ammo:", weapon.ammo)
        GiveWeaponToPed(ped, GetHashKey(weapon.name), weapon.ammo, false, true)
    end
end)

AddEventHandler('playerSpawned', function()
    Citizen.Wait(2000) -- Wait to make sure ped is valid
    TriggerServerEvent('weaponshop:requestWeapons')
end)
