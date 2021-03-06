#!/usr/bin/env lua

--------------------------------------------------
--          AMORA COURSE SCAFFOLDER
--
-- Author: Andre Alves Garzia <andre@amoralabs.com>
-- Date: 22/09/2016
--
-- Reads `course.toml` file from a course and loop
-- all languages checking `flow` and create empty
-- files for all steps present in `flow`.
--
-- Used when creating new courses. Needs to be called
-- passing a parameter called `course` passing then
-- path to the folder where `course.toml` is.
--
-- REQUIREMENTS:
--  luaFileSystem
--  lua-toml
--  penlight
--
---------------------------------------------------

require "pl" -- injects all penlight modules in global
local TOML = require "toml"
local lfs = require "lfs"

----------------------------------------------------
--    check for arguments... 
--    needs to be called like:
--        lua scaffold.lua --course=path/to/course
----------------------------------------------------

local args = app.parse_args()

if args["course"] == nil then
    utils.quit(1, "error: please set course param")
end

----------------------------------------------------
-- We have a course param, check if folder exists
----------------------------------------------------

local coursePath = args["course"]
local exists = lfs.chdir(coursePath)

if exists == nil then
    utils.quit(1, "Error: path doesn't exist")
end 

---------------------------------------------------
-- pick course.toml and process it by
-- creating all files needed for all languages
-- present
---------------------------------------------------

if not path.exists("course.toml") then
    utils.quit(1, "Error: no course.toml")
end

local courseToml = file.read("course.toml")
local courseConfig = TOML.parse(courseToml, {strict=false})

print("Scaffolding course:",courseConfig[courseConfig["defaultLanguage"]]["name"])

for k, v in pairs(courseConfig) do 
    -- Skip `defaultLanguage` key, all other course.toml keys
    -- are language entries which should hold flow elements.
    if k == "defaultLanguage" then
        goto fim
    end 

    if courseConfig[k]["flow"] ~= nil then
        -- pick the list of paths on `flow` and create
        -- all folders needed and also place an empty file
        -- for all files needed.
        for i,arquivo in pairs(courseConfig[k]["flow"]) do
            if not path.exists(arquivo) then
                dir.makepath(path.dirname(arquivo))
                file.write(arquivo, "")
                print("Created:", arquivo)
            end
        end
    end

    ::fim::
end

---------------------------------------------------------
-- Each course will end up living in its own git repo
-- So, generate a README.md from content of course.toml
---------------------------------------------------------
local readmeTemplate = text.Template([[
    # ${title}
    ${description}

    --
    [Amora Academy](https://amora.academy)
]])

file.write("README.md", readmeTemplate:substitute {
    title = courseConfig[courseConfig["defaultLanguage"]]["name"],
    description = courseConfig[courseConfig["defaultLanguage"]]["blurb"]
})



