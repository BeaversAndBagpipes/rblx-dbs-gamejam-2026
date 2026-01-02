-- Lune libs
local fs      = require("@lune/fs")
local process = require("@lune/process")
local serde   = require("@lune/serde")


-- Main
local function dotenv()
    local content

    if fs.isFile(`{process.cwd}/.env`) then  --check the immediate directory
        content = fs.readFile(`{process.cwd}/.env`)
	elseif fs.isFile(`{process.cwd}/../.env`) then --check the parent directory
		content = fs.readFile(`{process.cwd}/../.env`)
	elseif fs.isFile(`{process.cwd}/../../.env`) then --check the parents-parent, the root of the project
		content = fs.readFile(`{process.cwd}/../../.env`)
	else
		warn("dotenv: Did not find .env file! Without this we can't do anything with Roblox's v1 API and the script will most likely fail.")
		return false
    end

    if content then
        for key, value in serde.decode("toml", content) do
            process.env[key] = value
        end
    end

    return process.env
end

return dotenv