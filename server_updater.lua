local repositoryOwner = "Derbosik"
local repositoryName = "3DEditor"

local localPath = "updates/"

function checkForUpdates()
    local apiUrl = "https://api.github.com/repos/" .. repositoryOwner .. "/" .. repositoryName .. "/releases/latest"

    fetchRemote(apiUrl, function(response, error)
        if error == 0 then
            local releaseInfo = fromJSON(response)
            local tagName = releaseInfo.tag_name

            if tagName then
                local localVersion = getVersion()

                if localVersion < tagName then
                    print("A new update is available! Downloading...")
                    downloadUpdate(tagName)
                else
                    print("You are already using the latest version.")
                end
            end
        else
            print("Failed to check for updates: " .. error)
        end
    end)
end

function downloadUpdate(version)
    local downloadUrl = "https://github.com/" .. repositoryOwner .. "/" .. repositoryName .. "/archive/" .. version .. ".zip"
    local localFilePath = localPath .. version .. ".zip"

    fetchRemote(downloadUrl, function(response, error)
        if error == 0 then
            local file = fileCreate(localFilePath)
            if file then
                fileWrite(file, response)
                fileClose(file)
                print("Update downloaded and saved to " .. localFilePath)
            else
                print("Failed to create the local file: " .. localFilePath)
            end
        else
            print("Failed to download update: " .. error)
        end
    end)
end

function getVersion()
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
addEventHandler("onResourceStart", resourceRoot, checkForUpdates)