local repositoryOwner = "YelehaUwU"
local repositoryName = "3DEditor"

local localPath = "updates/"

local outputServerLog_ = outputServerLog
local outputServerLog = function(message)
    outputServerLog_("[" .. repositoryName .. "] » " .. message)
    print("[" .. repositoryName .. "] » " .. message)
end

local checkForUpdates, downloadUpdate, getVersion

checkForUpdates = function()
    local apiUrl = "https://api.github.com/repos/" .. repositoryOwner .. "/" .. repositoryName .. "/releases/latest"

    fetchRemote(apiUrl, function(response, error)
        if error == 0 then
            local releaseInfo = fromJSON(response)
            local tagName = releaseInfo.tag_name

            if tagName then
                local localVersion = getVersion()

                if localVersion < tagName then
                    outputServerLog("A new update is available! Downloading...")
                    downloadUpdate(tagName)
                else
                    outputServerLog("You are already using the latest version.")
                end
            end
        else
            outputServerLog("Failed to check for updates: " .. error)
        end
    end)
end
addEventHandler("onResourceStart", resourceRoot, checkForUpdates, false)

downloadUpdate = function(version)
    local downloadUrl = "https://github.com/" .. repositoryOwner .. "/" .. repositoryName .. "/archive/" .. version .. ".zip"
    local localFilePath = localPath .. version .. ".zip"

    fetchRemote(downloadUrl, function(response, error)
        if error == 0 then
            local file = fileCreate(localFilePath)
            if file then
                fileWrite(file, response)
                fileClose(file)
                outputServerLog("Update downloaded and saved to " .. localFilePath)
            else
                outputServerLog("Failed to create the local file: " .. localFilePath)
            end
        else
            outputServerLog("Failed to download update: " .. error)
        end
    end)
end

getVersion = function()
    local metaFile = xmlLoadFile("meta.xml")
    
    if metaFile then
        local infoNode = xmlFindChild(metaFile, "info", 0)
        if infoNode then
            local version = xmlNodeGetAttribute(infoNode, "version")
            xmlUnloadFile(metaFile)
            if version then
                return version
            end
        end
        xmlUnloadFile(metaFile)
    end

    return "1.0"
end
