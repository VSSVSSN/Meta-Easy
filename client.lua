function loadMeta(metaType, isInterior, isIPL)
    local metaPaths = {}
    
    local searchPaths = {
        "citizen\\common\\data\\",
        "citizen\\platform\\data\\",
        "update\\update.rpf\\",
        "update\\x64\\dlcpacks\\",
        "mpheist3\\mpheist3.rpf\\",
        "mpheist\\mpheist.rpf\\",
        "mpbusiness2\\mpbusiness2.rpf\\",
        "mpbusiness\\mpbusiness.rpf\\",
        "mpexecutive\\mpexecutive.rpf\\",
        "mpgunrunning\\mpgunrunning.rpf\\",
        "mphalloween\\mphalloween.rpf\\",
        "mplowrider\\mplowrider.rpf\\",
        "mpluxe\\mpluxe.rpf\\",
        "mpluxe2\\mpluxe2.rpf\\",
        "mpluxeapartments\\mpluxeapartments.rpf\\",
        "mpsmuggler\\mpsmuggler.rpf\\",
        "mpstunt\\mpstunt.rpf\\",
        "mpvalentines2\\mpvalentines2.rpf\\",
        "mpxmas2\\mpxmas2.rpf\\"
    }

    for _, searchPath in ipairs(searchPaths) do
        if isInterior then
            searchPath = searchPath .. "x64\\levels\\gta5\\interiors\\"
        elseif isIPL then
            local iplProps = {
                "prop_a4_pile_01",
                "prop_a4_sheet_01",
                "prop_a4_sheet_02",
                -- add more props here as needed
            }
            local iplPropsStr = table.concat(iplProps, "|")
            searchPath = searchPath .. "x64w.rpf\\levels\\gta5\\_cityw\\_cityw_10\\cityw_10_props.rpf\\"
            findMetaFiles(searchPath, iplPropsStr, metaPaths)
        else
            searchPath = searchPath .. "data\\"
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
    
    return metaPaths
end

function fileExists(resourceName, fileName)
    local data = LoadResourceFile(resourceName, fileName)
    if data then
        return true
    else
        return false
    end
end


function findMetaFiles(path, pattern, metaPaths, ...)
    local files = {}
    for file in string.gmatch(listFiles(path), "[^\r\n]+") do
        table.insert(files, file)
    end

    for _, file in ipairs(files) do
        if string.match(file, pattern) then
            local meta = {}
            for _, field in ipairs({...}) do
                local value = string.match(file, field .. "_(%w+)")
                if value then
                    meta[field] = value
                end
            end
            meta.path = file
            table.insert(metaPaths, meta)
        end
    end
end

function listFiles(path)
    local files = {}
    local data = LoadResourceFile(GetCurrentResourceName(), path)
    if not data then
        return files
    end

    for line in string.gmatch(data, "[^\r\n]+") do
        table.insert(files, line)
    end

    return files
end
