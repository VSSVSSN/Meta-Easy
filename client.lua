function loadMeta(metaType, isInterior, isIPL, metaDataTable, vehiclesTable)
    local metaPaths = {}

    -- metaTypes table to specify the parameters for each type of metadata
    local metaTypes = {
        vehicles = {"vehicles.meta$", "handlingName", "modelName", "type"},
        handling = {"handling.meta$", "handlingName", "attributeName", "type"},
        carcols = {"carcols.meta$", "modelName", "colorType", "colorIndex"},
        carvariations = {"carvariations.meta$", "modelName", "variationName", "variationValue"},
        vehiclelayouts = {"vehiclelayouts.meta$", "modelName", "layoutName", "layoutValue"}
    }

    -- Add search paths for metadata
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

    -- Add update files to search paths
    local updatePath = "update\\"
    local updateFiles = listFilesRecursive(updatePath, ".rpf")
    for _, updateFile in ipairs(updateFiles) do
        table.insert(searchPaths, updatePath .. updateFile)
    end

    -- Find meta files in search paths
    for _, searchPath in ipairs(searchPaths) do
        local metaTypeParams = metaTypes[metaType]
        if metaTypeParams then
            local metaFile = searchPath .. (isInterior and "x64\\levels\\gta5\\interiors\\" or "") .. (isIPL and "x64w.rpf\\levels\\gta5\\_cityw\\_cityw_10\\cityw_10_props.rpf\\" or "") .. "data\\" .. metaTypeParams[1]
            if fileExists(metaFile) then
                local metaXml = LoadResourceFile(GetCurrentResourceName(), metaFile)
                local metaNodes = GetXmlNodes(metaXml, "Item")
                for _, metaNode in ipairs(metaNodes) do
                    local metaItem = {}
                    metaItem[metaTypeParams[2]] = GetXmlString(metaNode, metaTypeParams[2])
                    metaItem[metaTypeParams[3]] = GetXmlString(metaNode, metaTypeParams[3])
                    metaItem[metaTypeParams[4]] = GetXmlString(metaNode, metaTypeParams[4])
                    if metaType == "vehicles" then
                        -- Add handling, carcols, carvariations, and vehiclelayouts meta data to the vehicles table
                        for subMetaType, subMetaParams in pairs(metaTypes) do
                           
					if subMetaType ~= "vehicles" then
						local subMetaTable = {}
						for _, metaItem in ipairs(metaDataTable[subMetaType]) do
							if metaItem[subMetaParams[2]] == vehData[2] then
								local subMeta = {}
								subMeta[subMetaParams[3]] = metaItem[subMetaParams[3]]
								subMeta[subMetaParams[4]] = metaItem[subMetaParams[4]]
								table.insert(subMetaTable, subMeta)
							end
						end
					if next(subMetaTable) ~= nil then
						vehicles[vehData[2]][subMetaType] = subMetaTable
					end
				end
			end
		end
	end
end

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    deferrals.defer()

    -- load metadata and store it in SRP.MetaData
    local metaType = "vehicles"
    local isInterior = false
    local isIPL = false
    loadMeta(metaType, isInterior, isIPL, SRP.MetaData)

    -- show player progress
    deferrals.update("Loading metadata...")
    
    -- defer until metadata is loaded
    Citizen.CreateThread(function()
        while #SRP.MetaData == 0 do
            Citizen.Wait(0)
        end
        deferrals.done()
    end)
end)

function loadMeta(metaType, isInterior, isIPL, metaDataTable)
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
            animations = {"anim\\*.meta", "AnimSet", "ClipSet", "Name"},
            cutscenes = {"cutscenes.meta", "cutName", "animName", "animDict"},
            vehiclelayouts = {"vehiclelayouts.meta$", "modelName", "layoutName", "type"}

        }
        for metaTypeName, metaTypeParams in pairs(metaTypes) do
            if metaType == metaTypeName then
                if metaType == "cutscenes" then
                findMetaFiles(searchPath, metaTypeParams[1], metaPaths, metaTypeParams[2], metaTypeParams[3], metaTypeParams[4], true)
            else
                findMetaFiles(searchPath, metaTypeParams[1], metaPaths, metaTypeParams[2], metaTypeParams[3], metaTypeParams[4])
            end
            if metaType == "vehiclelayouts" then
                findMetaFiles(searchPath, metaTypeParams[1], metaPaths, metaTypeParams[2], metaTypeParams[3], metaTypeParams[4])
            end
        end
    end
    -- add meta data to the metaDataTable
    for _, meta in ipairs(metaPaths) do
        local metaTable = {}
        local metaXml = LoadResourceFile(GetCurrentResourceName(), meta)
        local metaNodes = GetXmlNodes(metaXml, "Item")
        for _, metaNode in ipairs(metaNodes) do
            local metaItem = {}
            for _, param in ipairs({...}) do
                metaItem[param] = GetXmlString(metaNode, param)
            end
            table.insert(metaTable, metaItem)
        end
        metaDataTable[string.gsub(meta, ".meta", "")] = metaTable
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

            -- Extract spawn locations
            if metaType == "vehicles" or metaType == "weapons" then
                local spawnLocations = {}
                local metaXml = LoadResourceFile(GetCurrentResourceName(), path .. file)
                local xmlRoot = xml.load(metaXml)
                if metaType == "vehicles" then
                    local spawnNodes = xmlRoot:findNodes("handlingData/spawnInfo/spawnName")
                    for _, spawnNode in ipairs(spawnNodes) do
                        local spawnName = xmlNodeGetValue(spawnNode)
                        if spawnName then
                            table.insert(spawnLocations, spawnName)
                        end
                    end
                elseif metaType == "weapons" then
                    local spawnNodes = xmlRoot:findNodes("WeaponDatas/WeaponData/Components/Component/Clip/Item")
                    for _, spawnNode in ipairs(spawnNodes) do
                        local spawnName = xmlNodeGetAttribute(spawnNode, "clipName")
                        if spawnName then
                            table.insert(spawnLocations, spawnName)
                        end
                    end
                end
            elseif metaType == "vehiclelayouts" then
                local layoutName = string.match(file, "layout_(%w+)")
                if layoutName then
                    meta["layoutName"] = layoutName
                end
            end
                meta.spawnLocations = spawnLocations
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
            animations = {"anim\\*.meta", "AnimSet", "ClipSet", "Name"},
            cutscenes = {"cutscenes.meta", "cutName", "animName", "animDict"}
        }

        for metaTypeName, metaTypeParams in pairs(metaTypes) do
            if metaType == metaTypeName then
                if metaType == "cutscenes" then
                findMetaFiles(searchPath, metaTypeParams[1], metaPaths, metaTypeParams[2], metaTypeParams[3], metaTypeParams[4], true)
            else
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
