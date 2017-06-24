timer = timer or require "timer"

local audioHandler

local function addFromAudioObject(audioObj, name)
    audioHandler.audioObjs[name] = audioObj
end

local audioDir = "/assets"

audioHandler = {
    audioObjs = {},
    filePriorities = {},
    extensionPriorities = {
        wav = 0,
        aac = 1,
        ogg = 2,
        mp3 = 3, --Smaller is better.
    },
    add = function(filePath, fileName)
        --- Adds an audio file into the audio subsystem. The file will override a file with the same name if
        --- it has an extension with higher priority, as defined in the extensionPriorities table.
        --- It will not load it if they are the same.
        --- It can be given a filepath, or an audio object and a name for the audio object.
        if fileName and type(filePath) ~= "string" then
            addFromAudioObject(filePath, fileName)
            return
        end
        local filePathWithoutExtension = filePath:sub(1, filePath:find(".", nil, true) and #filePath - filePath:reverse():find(".", nil, true) or #filePath)
        local extension = filePath:sub(#filePathWithoutExtension + 2 - #audioDir)
        local name = filePathWithoutExtension:sub(#audioDir)
        if audioHandler.audioObjs[fileName or name] then
            local extensionPriority = audioHandler.extensionPriorities[extension]
            if extensionPriority and extensionPriority <= audioHandler.filePriorities[fileName or name] then
                print(("Tried to load %s, but priority was lower than existing audio file."):format(filePath))
                return
            end
        end
        audioHandler.audioObjs[fileName or name] = love.audio.newSource(filePath, "static")
        audioHandler.filePriorities[fileName or name] = audioHandler.extensionPriorities[extension] or 0
    end,
    remove = function(fileName)
        --- Removes the audio object with the given name from the audio handler, if it exists.
        audioHandler.audioObjs[fileName] = nil
        audioHandler.filePriorities[fileName] = nil
    end,
    play = function(fileName, callback)
        --- Plays the audio object with the given name from the audio handler, if it exists.
        local audioObj = audioHandler.audioObjs[fileName]
        if audioObj then
            love.audio.play(audioObj)
        else
            error(("No audio file with filename %s found."):format(fileName))
        end
        if type(callback) == "function" then
            timer.when(function() return audioObj:isStopped() end, callback)
        end
    end,
    stop = function(fileName)
        --- Stops playing the audio object with the given name from the audio handler, if it exists.
        local audioObj = audioHandler.audioObjs[fileName]
        if audioObj then
            love.audio.stop(audioObj)
        end
    end
}

local files = { names = {}, priority = {}, extensions = {} }
for _, v in pairs(love.filesystem.getDirectoryItems(audioDir)) do
    local filePathWithoutExtension = audioDir .. (v:sub(1, v:find(".", nil, true) and #v - v:reverse():find(".", nil, true) or #v))
    local name = filePathWithoutExtension:sub(#audioDir+1)
    local extension = v:find(".", nil, true) and v:sub(#filePathWithoutExtension + 2 - #audioDir) or nil
    if audioHandler.extensionPriorities[extension] then
        if not files.priority[name] or files.priority[name] > audioHandler.extensionPriorities[extension] then
            files.names[name] = true
            files.priority[name] = audioHandler.extensionPriorities[extension]
            files.extensions[name] = extension
        end
    end
end

for k in pairs(files.names) do
    audioHandler.add(("%s/%s.%s"):format(audioDir, k, files.extensions[k]), k)
end
files = nil

return setmetatable(audioHandler, { __index = audioHandler.audioObjs })