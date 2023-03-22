function loadMeta(metaType, isInterior, isIPL)
    local metaPaths = {}
    
    local searchPaths = {
        "citizen\\common\\data\\",
        "citizen\\platform\\data\\",
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
    
    -- Find all RPF files in the update folder and its subfolders
    local updateFiles = {}
    local updatePath = "update\\"
    local function findUpdateFiles(path)
        for _, fileName in ipairs(listFiles(path)) do
            if fileName:sub(-4) == ".rpf" then
                table.insert(updateFiles, path .. fileName)
            elseif fileName:sub(-1) == "\\" then
                findUpdateFiles(path .. fileName)
            end
        end
    end
    findUpdateFiles(updatePath)
    
    -- Add update files to search paths
    for _, updateFile in ipairs(updateFiles) do
        table.insert(searchPaths, updateFile)
    end

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
        
        local metaTypes = {
            shop_clothes = {"shop_clothes.meta$", "gender", "item", "id"},
            vehicles = {"vehicles.meta$", "handlingName", "modelName", "type"},
            carcols = {"carcols.meta$", "modelName", "colorType", "id"},
            carvariations = {"carvariations.meta$", "modelName", "variationName", "type"},
            handling = {"handling.meta$", "handlingName", "attributeName", "type"},
            weapons = {"weapons.meta$", "weaponName", "componentName", "type"},
            animations = {"anim\\*.meta", "AnimSet", "ClipSet", "Name"}
        }

        for metaTypeName, metaTypeParams in pairs(metaTypes) do
            if metaType == metaTypeName then
                findMetaFiles(searchPath, metaTypeParams[1], metaPaths, metaTypeParams[2], metaTypeParams[3], metaTypeParams[4])
            end
        end
    end
    return metaPaths
end

function findMetaFiles(path, pattern, metaPaths, ...)
    local files = {}
    Citizen.InvokeNative(0x5F695EEF92862B22, path) -- STREAMING::OPEN_PACKFILE

    while true do
        local file = Citizen.InvokeNative(0x3D593694C6B0D5CD) -- STREAMING::GET_PACKFILE_FILE_INFO
        if not file then
            break
        end

        if string.match(file, pattern) then
            local meta = {}
            for _, field in ipairs({...}) do
                local value = string.match(file, field .. "_(%w+)")
                if value then
                    meta[field] = value
                end
            end

            if metaType == "animations" and meta["AnimSet"] == animSet then
                local clipSet = meta["ClipSet"]
                if clipSet then
                    meta["ClipSet"] = string.gsub(clipSet, "clipset_", "")
                end
            end

            meta.path = file
            table.insert(metaPaths, meta)
        end
    end

    Citizen.InvokeNative(0x02A8BEC6FD91BCE3) -- STREAMING::CLOSE_PACKFILE
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

function fileExists(resourceName, fileName)
    local data = LoadResourceFile(resourceName, fileName)
    if data then
        return true
    else
        return false
    end
end

function findClipSetForAnimSet(animSet)
    local metaPaths = loadMeta("animations")
    for _, meta in ipairs(metaPaths) do
        if meta.AnimSet == animSet and meta.Name == "default" then
            return meta.ClipSet
        end
    end
    return nil
end
