--- A class handling the playing, pausing, and looping of audio.
--- @classmod audioHandler

local scheduler = require "scheduler"
local loader = require "love-loader.love-loader"

local audioHandler

local function addFromAudioObject(audioObj, name)
    audioHandler.audioObjs[name] = audioObj
end

local audioDir = "/assets"

audioHandler = {
    audioObjs = {},
    filePriorities = {},
    playing = {},
    extensionPriorities = {
        wav = 0,
        aac = 1,
        ogg = 2,
        mp3 = 3, --Smaller is better.
    }
}
--- Adds an audio file into the audio subsystem. The file will override a file with the same name if
--- it has an extension with higher priority, as defined in the extensionPriorities table.
--- It will not load it if they are the same.
--- It can be given a filepath, or an audio object and a name for the audio object.
--- @tparam string filePath The path to the audio file.
--- @tparam string fileName The name of the file to add to the audio handler.
--- @return nil
function audioHandler.add(filePath, fileName)
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
    if loadingAssets then
        loader.newSource(audioHandler.audioObjs, fileName or name, filePath, "static")
    else
        audioHandler.audioObjs[fileName or name] = love.audio.newSource(filePath, "static")
    end
    audioHandler.filePriorities[fileName or name] = audioHandler.extensionPriorities[extension] or 0
end

--- Removes the audio object with the given name from the audio handler, if it exists.
---@tparam string fileName The name of the file to remove from the audio handler.
---@return nil
function audioHandler.remove(fileName)
    audioHandler.audioObjs[fileName] = nil
    audioHandler.filePriorities[fileName] = nil
end

--- Plays the audio object with the given name from the audio handler, if it exists. Returns a function to stop playing the audio file.
---@tparam string fileName The name of the file to play.
--- @tparam function|nil callback (Optional) A callback to run when the file stops playing.
---@treturn function A function which will cancel the playing of this file. If a truthy value is passed and callback is a function, it will also be run.
function audioHandler.play(fileName, callback)
    local audioObj = audioHandler.audioObjs[fileName]
    assert(audioObj, ("No audio file with filename %s found."):format(fileName))
    if audioObj then
        audioObj:play()
    end
    local cancelFct
    cancelFct = scheduler.when(function()
        return audioObj:isStopped()
    end, function()
        audioHandler.playing[fileName] = nil
        if type(callback) == "function" then
            callback()
        end
    end)
    local cancel = function(runCallback)
        cancelFct()
        if runCallback and type(callback) == "function" then
            callback()
        end
        audioObj:stop()
    end
    audioHandler.playing[fileName] = cancel
    return cancel
end

--- Loops the audio object with the given name from the audio handler, if it exists. Returns a function to stop playing the audio file.
---@tparam string fileName The name of the file to play.
--- @tparam function|nil callback (Optional) A callback to run when the file loops.
---@treturn function A function which will cancel the playing of this file. If a truthy value is passed and callback is a function, it will also be run.
function audioHandler.loop(fileName, callback)
    local audioObj = audioHandler.audioObjs[fileName]
    if audioObj then
        audioObj:play()
    else
        error(("No audio file with filename %s found."):format(fileName))
    end
    local cancelFct = scheduler.everyCondition(function()
        return audioObj:isStopped()
    end, function()
        audioObj:play()
    end, function()
        audioObj:stop()
        audioHandler.playing[fileName] = nil
    end)
    local cancel = function(runCallback)
        cancelFct()
        if runCallback and type(callback) == "function" then
            callback()
        end
    end
    audioHandler.playing[fileName] = cancel
    return cancel
end

---Pauses all playing audio.
---@return nil.
function audioHandler.pauseAll()
    for k, _ in pairs(audioHandler.playing) do
        audioHandler.pause(k)
    end
end

---Resumes all paused audio.
---@return nil
function audioHandler.resumeAll()
    for k, _ in pairs(audioHandler.playing) do
        audioHandler.resume(k)
    end
end

--- Stops playing the audio object with the given name from the audio handler, if it exists.
---@tparam string fileName The name of the file to stop.
---@return nil
function audioHandler.stop(fileName)
    local audioObj = audioHandler.audioObjs[fileName]
    assert(audioObj, ("No audio object with name %s found."):format(fileName))
    love.audio.stop(audioObj)
end

--- Pauses the audio object with the given name from the audio handler, if it exists.
---@tparam string fileName The name of the file to pause.
---@return nil
function audioHandler.pause(fileName)
    local audioObj = audioHandler.audioObjs[fileName]
    assert(audioObj, ("No audio object with name %s found."):format(fileName))
    audioObj:pause()
end

--- Resumes the audio object with the given name from the audio handler, if it exists.
---@tparam string fileName The name of the file to resume.
---@return nil
function audioHandler.resume(fileName)
    local audioObj = audioHandler.audioObjs[fileName]
    assert(audioObj, ("No audio object with name %s found."):format(fileName))
    audioObj:resume()
end

local files = { names = {}, priority = {}, extensions = {} }

--Grab all the audio files
for _, v in pairs(love.filesystem.getDirectoryItems(audioDir)) do
    local filePathWithoutExtension = audioDir .. (v:sub(1, v:find(".", nil, true) and #v - v:reverse():find(".", nil, true) or #v))
    local name = filePathWithoutExtension:sub(#audioDir + 1)
    local extension = v:find(".", nil, true) and v:sub(#filePathWithoutExtension + 2 - #audioDir) or nil
    if audioHandler.extensionPriorities[extension] then
        if not files.priority[name] or files.priority[name] > audioHandler.extensionPriorities[extension] then
            files.names[name] = true
            files.priority[name] = audioHandler.extensionPriorities[extension]
            files.extensions[name] = extension
        end
    end
end

--Add them all
for name in pairs(files.names) do
    audioHandler.add(("%s/%s.%s"):format(audioDir, name, files.extensions[name]), name)
end
files = nil

return setmetatable(audioHandler, { __index = audioHandler.audioObjs })