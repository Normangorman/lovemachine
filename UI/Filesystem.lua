local Filesystem = {}

function Filesystem.tableToString(tbl)
    local result, done = {}, {}

    for k, v in ipairs(tbl) do
        table.insert(result, Filesystem.val_to_str(v))
        done[k] = true
    end

    for k, v in pairs(tbl) do
        if not done[k] then
            table.insert(result, Filesystem.key_to_str( k ) .. "=" .. Filesystem.val_to_str(v))
        end
    end

    return "{" .. table.concat(result, ",") .. "}"
end

function Filesystem.val_to_str(v)
    if "string" == type(v) then
        v = string.gsub(v, "\n", "\\n")
        if string.match(string.gsub(v,"[^'\"]",""), '^"+$') then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v,'"', '\\"') .. '"'
    else
        return "table" == type(v) and Filesystem.tableToString(v) or tostring(v)
    end
end

function Filesystem.key_to_str(k)
    if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
        return k
    else
        return "[" .. Filesystem.val_to_str(k) .. "]"
    end
end

-- Attempt to make a directory. Return true if succesful or it already exists. False otherwise.
function Filesystem.mkdir(folder_name)
    if love.filesystem.exists(folder_name) then
        return true
    else
        return love.filesystem.createDirectory(folder_name)
    end
end

function Filesystem.debug()
    print("FILE SYSTEM DATA:")
    print("AppdataDirectory:", love.filesystem.getAppdataDirectory())
    print("DirectoryItems:", love.filesystem.getDirectoryItems("", function(name) print(name) end))
    print("Identity:", love.filesystem.getIdentity())
    print("SaveDirectory:", love.filesystem.getSaveDirectory())
    print("SourceBaseDirectory:", love.filesystem.getSourceBaseDirectory())
    print("UserDirectory:", love.filesystem.getUserDirectory())
    print("WorkingDirectory:", love.filesystem.getWorkingDirectory())
    print("")
end

-- Returns a boolean success value and possibly an error string if not successful.
function Filesystem.saveTable(table, file_name)
    print("Filesystem.saveTable - saving table to "..file_name)
    Filesystem.debug()

    local tableString = Filesystem.tableToString(table)
    local file, errorString = love.filesystem.newFile(file_name)

    if file then
        print "File object created."
    else
        print("Could not create file object:", errorString)
        return false, errorString
    end

    local success, errorString = file:open('w')
    if success then 
        print "File opened."
    else
        print("Success:", tostring(success))
        print("Could not open file:", errorString)
        return false, errorString
    end

    local data = "return " .. tableString
    success, errorString = file:write(data)
    if success then
        print("Write was successful.")
    else
        print("Write was not successful:", errorString)
        return false, errorString
    end

    file:flush()
    file:close()

    return true
end

return Filesystem
