-- Initialization file for KUAL, Lua extensions
-- This file should reside alongside the config.xml and menu.json files
-- It should not require any changes, although it can be changed if required.
--
-- This file will be pre-loaded by Lua under control of the script's #! first line.
--
-- The following overrides the Lab126 Lua build setting with the actual paths
-- used by Lab126 plus the paths used by our own KUAL-system extensions.
--
-- By convention, the current working directory is searched first.
-- When KUAL runs a button extension, the directory of config.xml, menu.json
-- and this file, esys.lua is the current working directory.
--
-- The search for add-in Lua modules searches the package.path search path
-- for source (text or pre-compiled) modules first.
--

local tpath = {
    [1] = "./?.lua",                                    -- current working directory
    [2] = "/mnt/us/esys/usr/share/lua5.1/?.lua",        -- our source-form modules
    [3] = "/mnt/us/esys/usr/share/lua5.1/?/init.lua",
    [4] = "/usr/lib/lua/?.lua",                         -- lab126 source-form modules
    [5] = "/usr/lib/lua/?/init.lua"
}

-- The search for add-in Lua modules next searchs the package.cpath search
-- path for binary modules.

local cpath = {
    [1] = "./?.so",                                     -- current working directory
    [2] = "/mnt/us/esys/usr/lib/lua5.1/?.so",           -- our binary-form modules
    [3] = "/mnt/us/esys/usr/lib/lua5.1/?/init.so",
    [4] = "/usr/lib/lua/?.so",                          -- lab126 binary-form modules
    [5] = "/usr/lib/lua/?/init.so"
}

-- Initialize Lua search paths, the path separator is ';'

package.path  = table.concat(tpath, ';')
package.cpath = table.concat(cpath, ';')

tpath, cpath = nil, nil                         -- all done with those
