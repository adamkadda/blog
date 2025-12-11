local start_time = os.clock()

local lfs = require("lfs") -- https://github.com/lunarmodules/luafilesystem
local toml = require("toml") -- https://github.com/nexo-tech/toml2lua

-- We need to parse the TOML frontmatter and truncate it from the file.
-- String operations are faster than IO, so we're reading the whole file.
local function consume(filename)
	local file = assert(io.open(filename, "r"))
	local content = file:read("*a")
	file:close()

	-- Find frontmatter delimiters, extract what's in between
	local delimA = content:find("+++\n")
	local delimB = delimA and content:find("\n+++\n", delimA + 4)

	local meta
	local rest

	if delimA and delimB then
		meta = content:sub(delimA + 4, delimB - 1)
		rest = content:sub(delimB + 5)
	end

	-- Find body start, extract from there, rewrite file
	local start = rest:find("^# ") or rest:find("\n# ")
	if not start then
		return error(string.format("%s no start"), filename)
	end

	local body
	if start == 1 then
		body = rest -- "^# " case
	else
		body = rest:sub(start + 1) -- "\n# " case
	end

	file = assert(io.open(filename, "w"))
	file:write(body)
	file:close()

	local out = toml.parse(meta)
	return out
end

-- 20771122 = (2077 * 10000) + (11 * 100) + 22
local function recency(x, y)
	local dateX = (x.date.year * 10000) + (x.date.month * 100) + x.date.day
	local dateY = (y.date.year * 10000) + (y.date.month * 100) + y.date.day
	return dateX > dateY
end

local function pad(n)
	return n < 10 and "0" .. n or tostring(n)
end

local function escape(s)
	return (
		s:gsub("[&<>'\"]", {
			["&"] = "&amp;",
			["<"] = "&lt;",
			[">"] = "&gt;",
			["'"] = "&#39;",
			['"'] = "&quot;",
		})
	)
end

local function rowMacro(meta)
	local tags = table.concat(meta.tags, ", ")
	local command = ("ROW([%s], [%s], [%s], %s, %s, %s, [%s])"):format(
		meta.title,
		escape(meta.title),
		meta.slug,
		meta.date.year,
		pad(meta.date.month),
		pad(meta.date.day),
		tags
	)
	return command
end

-- Keeping things simple, not that many placeholders anyways.
local function post(template, meta, buildfile)
	-- expand macros in buildfile -> redirect to temp.txt -> convert to html
	local m4 = "m4 post.m4 " .. buildfile .. " > temp.txt"
	local pandoc = "pandoc -f markdown+raw_html temp.txt -t html -o " .. buildfile

	os.execute(m4)
	os.execute(pandoc)
	os.remove("temp.txt")

	local file = assert(io.open(buildfile))
	local body = file:read("*a")
	file:close()

	local content = template:gsub("{{%s*TITLE%s*}}", meta.title)
	content = content:gsub("{{%s*BODY%s*}}", body)

	local out = assert(io.open(("posts/%s.html"):format(meta.slug), "w"))
	out:write(content)
	out:close()
end

local function index(template, data)
	os.execute("touch rows.txt")

	for _, meta in pairs(data) do
		local temp = assert(io.open("temp.txt", "w"))
		temp:write(rowMacro(meta))
		temp:close()
		os.execute("m4 post.m4 temp.txt >> rows.txt")
	end
	os.remove("temp.txt")

	local file = assert(io.open("rows.txt"))
	local rows = file:read("*a")
	file:close()
	os.remove("rows.txt")

	local content = template:gsub("{{%s*ROWS%s*}}", rows)

	local out = assert(io.open("index.html", "w"))
	out:write(content)
	out:close()
end

local function pprint(tbl, indent, seen)
	indent = indent or 0
	seen = seen or {}

	if seen[tbl] then
		print(string.rep(" ", indent) .. "*cycle*")
		return
	end
	seen[tbl] = true

	if type(tbl) ~= "table" then
		print(string.rep(" ", indent) .. tostring(tbl))
		return
	end

	print(string.rep(" ", indent) .. "{")
	for k, v in pairs(tbl) do
		local key = tostring(k)
		io.write(string.rep(" ", indent + 2) .. key .. " = ")

		if type(v) == "table" then
			pprint(v, indent + 2, seen)
		else
			print(tostring(v))
		end
	end
	print(string.rep(" ", indent) .. "}")
end

local file = assert(io.open("templates/index.html"))
local indexTemplate = file:read("*a")
file:close()

file = assert(io.open("templates/post.html"))
local postTemplate = file:read("*a")
file:close()

-- script.lua expects one argument i.e. the build directory
local build = arg[1]
if build == "source" then
	error("phew! you almost fed me source...")
end

local data = {}

os.execute("mkdir -p posts")

for file in lfs.dir(build) do
	if file:match("%.txt$") then
		local buildfile = build .. "/" .. file
		local meta = consume(buildfile)
		post(postTemplate, meta, buildfile)
		data[#data + 1] = meta
	end
end

table.sort(data, recency)
index(indexTemplate, data)

local time_elapsed = os.clock() - start_time
print(string.format("script.lua runtime: %ss", time_elapsed))
