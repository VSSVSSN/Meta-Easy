function loadMeta(metaType, isInterior, isIPL)
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
                elseif isIPL then
                    local iplProps = {
                        "prop_a4_pile_01",
                        "prop_a4_sheet_01",
                        "prop_a4_sheet_02",
                        -- add more props here as needed
                    }
                    local iplPropsStr = table.concat(iplProps, "|")
                    searchPath = path .. "\\x64w.rpf\\levels\\gta5\\_cityw\\_cityw_10\\cityw_10_props.rpf\\"
                    findMetaFiles(searchPath, iplPropsStr, metaPaths)
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
