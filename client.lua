function loadMeta(metaType, isInterior)
    local gameDirs = {
        "C:\\Program Files\\Rockstar Games\\Grand Theft Auto V",
        "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Grand Theft Auto V"
    }
    local metaPaths = {}
    local drives = io.popen('wmic logicaldisk get caption'):read('*a')
    
    for drive in string.gmatch(drives, "%a:") do
        for _, gameDir in pairs(gameDirs) do
            local path = gameDir
            
            if not fileExists(path) then
                path = drive .. "\\Program Files\\Rockstar Games\\Grand Theft Auto V"
            end
            
            if not fileExists(path) then
                path = drive .. "\\Program Files (x86)\\Steam\\steamapps\\common\\Grand Theft Auto V"
            end
            
            if fileExists(path) then
                local searchPath
                
                if isInterior then
                    searchPath = path .. "\\x64\\levels\\gta5\\interiors\\"
                else
                    searchPath = path .. "\\update\\x64\\dlcpacks\\"
                end
                
                if metaType == "shop_clothes" then
                    findMetaFiles(searchPath, "shop_clothes.meta$", metaPaths, "gender", "item", "id")
                elseif metaType == "vehicles" then
                    findMetaFiles(searchPath, "vehicles.meta$", metaPaths, "handlingName", "modelName", "type")
                elseif metaType == "carcols" then
                    findMetaFiles(searchPath, "carcols.meta$", metaPaths, "modelName", "colorType", "id")
                elseif metaType == "carvariations" then
                    findMetaFiles(searchPath, "carvariations.meta$", metaPaths, "modelName", "variationName", "type")
                elseif metaType == "handling" then
                    findMetaFiles(searchPath, "handling.meta$", metaPaths, "handlingName", "attributeName", "type")
                elseif metaType == "weapons" then
                    findMetaFiles(searchPath, "weapons.meta$", metaPaths, "weaponName", "componentName", "type")
                elseif metaType == "weather" then
                    findMetaFiles(searchPath, "weather.xml$", metaPaths, "weatherName", "valueName", "type")
                else
                    findMetaFiles(searchPath, metaType .. "$", metaPaths)
                end
            end
        end
    end
    
    return metaPaths
end



--[[
    Example 1: Loading clothing shop metadata

    local shopClothesMetaPaths = loadMeta("shop_clothes")

    for _, path in ipairs(shopClothesMetaPaths) do
        -- do something with the metadata file at 'path'
    end

    Example 2: Loading vehicle metadata

    local vehicleMetaPaths = loadMeta("vehicles")

    for _, path in ipairs(vehicleMetaPaths) do
        -- do something with the metadata file at 'path'
    end

    Example 3: Loading carcols metadata


    local carcolsMetaPaths = loadMeta("carcols")

    for _, path in ipairs(carcolsMetaPaths) do
        -- do something with the metadata file at 'path'
    end

    Example 4: Loading handling metadata

    local handlingMetaPaths = loadMeta("handling")

    for _, path in ipairs(handlingMetaPaths) do
        -- do something with the metadata file at 'path'
    end



    Example 5: Loading metadata with a custom file name pattern

    local customMetaPaths = loadMeta("my_custom_metadata_file")

    for _, path in ipairs(customMetaPaths) do
        -- do something with the metadata file at 'path'
    end

    Example to get the vehicle variations for the current vehicle you're in:
    
    -- Get the current vehicle
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)

    -- Get the vehicle model name
    local model = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(model)

    -- Load the carvariations meta files
    local metaPaths = loadMeta("carvariations")

    -- Search for the meta file corresponding to the current vehicle model
    local carvariationsMeta = nil
    for _, metaPath in pairs(metaPaths) do
        local meta = loadMetaFile(metaPath)
        if meta[modelName] ~= nil then
            carvariationsMeta = meta[modelName]
            break
        end
    end
    
    -- If we found the carvariations meta file for the current vehicle model, print out the variation names
    if carvariationsMeta ~= nil then
        for _, variation in pairs(carvariationsMeta) do
            print(variation.variationName)
        end
    else
        print("No carvariations meta file found for "..modelName)
    end

    -- Upgrade a vehicle example:

    -- Load the vehicle's meta files
    local handlingMetas = loadMeta("handling")
    local carcolsMetas = loadMeta("carcols")
    local carvariationsMetas = loadMeta("carvariations")

    -- Find the meta file for the vehicle you want to upgrade
    local modelName = "adder" -- replace this with the name of the vehicle you want to upgrade
    local handlingMeta, carcolsMeta, carvariationsMeta
    for _, meta in ipairs(handlingMetas) do
        if meta.handlingName == modelName then
            handlingMeta = meta
            break
        end
    end
    for _, meta in ipairs(carcolsMetas) do
        if meta.modelName == modelName then
            carcolsMeta = meta
            break
        end
    end
    for _, meta in ipairs(carvariationsMetas) do
        if meta.modelName == modelName then
            carvariationsMeta = meta
            break
        end
    end

    -- Upgrade the vehicle
    if handlingMeta then
        -- Set the top speed and acceleration to the maximum values
        handlingMeta.topSpeed = 9999.0
        handlingMeta.acceleration = 9999.0

        -- Save the changes
        saveMeta(handlingMeta)
    end
    if carcolsMeta then
        -- Set the primary color to black and the secondary color to white
        carcolsMeta.color1.red = 0
        carcolsMeta.color1.green = 0
        carcolsMeta.color1.blue = 0
        carcolsMeta.color2.red = 255
        carcolsMeta.color2.green = 255
        carcolsMeta.color2.blue = 255

        -- Save the changes
        saveMeta(carcolsMeta)
    end
    if carvariationsMeta then
        -- Add a turbo upgrade to the vehicle
        carvariationsMeta.variations[1].upgrade = "turbo"

        -- Save the changes
        saveMeta(carvariationsMeta)
    end
    
    This example upgrades the handling, primary and secondary colors, and adds a turbo upgrade to the "adder" vehicle. You can modify the code to upgrade a different vehicle or change the upgrades applied.

    -- IPL example:

    local iplType = "ipl"
    local isInterior = false -- set to false for ipl

    -- load all ipls
    local iplPaths = loadMeta(iplType, isInterior)

    -- load the first ipl found
    if #iplPaths > 0 then
        local iplPath = iplPaths[1]
        loadIpl(iplPath)
    end

    In this example, we first specify that we want to load an ipl by setting the iplType variable to "ipl". We then set isInterior to false to indicate that we want to load an ipl (as opposed to an interior).

    We then call the loadMeta() function with these parameters to get a list of all the ipls that can be found in the game directories. In this example, we assume that there is at least one ipl file that can be found, so we simply load the first one by calling loadIpl() with its path.

    Of course, you would need to define the loadIpl() function as well to actually load the ipl file.


    -- Load interior example:

    -- Define the interior name
    local interiorName = "int01_ba_mpgarage"

    -- Load the meta files for the interior
    local metaPaths = loadMeta(interiorName, true)

    -- Load the interior
    if #metaPaths > 0 then
        for _, metaPath in ipairs(metaPaths) do
            loadInterior(metaPath)
        end
    else
        print("Could not find meta files for interior: " .. interiorName)
    end

    In this example, we first define the name of the interior we want to load (int01_ba_mpgarage). Then, we call the loadMeta function with the interiorName parameter set to this value and the isInterior parameter set to true to indicate that we want to load an interior. This will return a table of file paths for the meta files that define the specified interior.

    Next, we check if there are any meta files returned by the loadMeta function. If there are, we loop through them and call the loadInterior function to load each one. If there are no meta files returned, we print an error message indicating that the specified interior could not be found.

    Set weather example:

    -- Load the weather meta files
    local metaPaths = loadMeta("weather")

    -- Set the weather to "EXTRASUNNY"
    SetWeatherTypeNowPersist("EXTRASUNNY")

    -- Set the time to 12:00 PM
    NetworkOverrideClockTime(12, 0, 0)

    -- Loop through each meta file path and load the weather values
    for _, path in ipairs(metaPaths) do
        local data = xmlLoadFile(path)
        if data then
            -- Find the "weather" elements
            local weathers = xmlNodeGetChildren(data)
            for _, weather in ipairs(weathers) do
                if xmlNodeGetName(weather) == "weather" then
                    local weatherName = xmlNodeGetAttribute(weather, "name")
                    if weatherName == "EXTRASUNNY" then
                        -- Find the "hour" and "minute" elements and set their values
                        local hourNode = xmlFindChild(weather, "hour", 0)
                        local minuteNode = xmlFindChild(weather, "minute", 0)
                        if hourNode and minuteNode then
                            local hour = tonumber(xmlNodeGetValue(hourNode))
                            local minute = tonumber(xmlNodeGetValue(minuteNode))
                            NetworkOverrideClockTime(hour, minute, 0)
                        end
                        break
                    end
                end
            end
            xmlUnloadFile(data)
        end
    end

    This code sets the weather to "EXTRASUNNY" and the time to 12:00 PM using the SetWeatherTypeNowPersist() and NetworkOverrideClockTime() functions respectively. It then loads all the weather.meta files using the loadMeta() function and loops through each file, finding the "weather" element with the name "EXTRASUNNY". It then finds the "hour" and "minute" elements within that "weather" element and sets the time to those values using NetworkOverrideClockTime().
]]