#!/usr/bin/lua -lesys

require'pl'
stringx.import()

local ok, md5 = pcall(require, md5)

-- Nicknames
local btag        = xml.tags
local append      = table.insert
local dwalk       = dir.walk
local basename    = path.basename
if ok then md5sum = md5.sumhexa else md5sum = function(s) return s end end

-- Tag generators
local line  = btag('li')
local unord = btag('ul')
local order = btag('ol')
local ddata = btag('dd')
local dtitl = btag('dt')
local dlist = btag('dl')
local bold  = btag('b')
local hdr1  = btag('h1')
local hdr2  = btag('h2')
local hdr3  = btag('h3')
local para  = btag('p')

local header  = [[
<!DOCTYPE html>
<html><head><TITLE>Report on CPU settings</TITLE></head><body>
]]
local page    = {}
local footer  = '</body></html>'

-- Indent generator
local indents = { [2] = '  ', [4] = '    ', [6] = '      ', [8] = '        ' }
local indent = function (n)
    if not indents[n] then indents[n] = string.rep(' ', n) end
    return indents[n]
end

-- Split a tag pair into open and close tag strings
local sTag   = function (tag) local ts = tostring(tag):split('|')
           return tostring(ts[1]), tostring(ts[2]) end

-- Fix-up titles ( _ -> ' ', Capitalize)
local proper = function (s) return stringx.title(string.gsub(s, "_", ' ')) end

-- Unescape things xml.tags shouldn't have escaped
local function unesc(s) 
    return tostring(s):gsub('&%a+;', {["&apos;"] = "'", ["&quot;"] = "\"", 
                            ["&lt;"] = "<", ["&gt;"] = ">", ["&amp;"] = "&"}) 
end

-- Concantenate strings - allow for tag-tables as arguments
local function splice (a, b) 
    return ('%s%s'):format(tostring(a), tostring(b)) 
end
    
local function splice3 (a, b, c) 
    return ('%s%s%s'):format(tostring(a), tostring(b), tostring(c)) 
end

local function splice4 (a, b, c, d) 
    return ('%s%s%s%s'):format(tostring(a), tostring(b), tostring(c), tostring(d)) 
end

local function get_uptime()
    local fd1 = io.open('/proc/uptime', 'r')
    local l = fd1:read('*line')
    fd1:close()
    local lt = l:split()
    return lt[1]    -- time since last boot in 'user time units' as seconds
end

-- Seconds to dd:hh:mm:ss
local function sec2time (n)
    local dy, hr, mn, sc, tmp
    dy = n / 86400
    hr = (dy - math.floor(dy)) * 24
    mn = (hr - math.floor(hr)) * 60
    sc = (mn - math.floor(mn)) * 60
    return (' \(%02d:%02d:%02d:%02d\)'):format(math.floor(dy), math.floor(hr), 
                                               math.floor(mn), math.floor(sc))
end

-- Kernel, user time units (10ms)
local function ms102time (n) return sec2time(n / 100) end

-- ms time units
local function ms2time (n) return sec2time(n / 1000) end

-- Descriptor list components
local dlOpen, dlClose = sTag(dlist('|'))
local ddOpen, ddClose = sTag(ddata(unord('|')))

--[[
    parm 1 : (string) raw form of descriptor title
    parm 2 : (string) raw form of descriptor values
    parm 3 : (string) 'owner' access permissions
    return : (string) html descriptor list string
--]]
local function dl_string (dl_title, dl_values, perm)
    local ddt
    local val = dl_values:strip():split()
    local dlt = {}
    append(dlt, splice(indent(4), dlOpen))
    if #val > 1 then
        append(dlt, splice(indent(8), dtitl(bold(splice(proper(dl_title), perm)))))
        append(dlt, splice(indent(8), ddOpen))
        if dl_title ~= 'time_in_state' then
            for _, v in pairs(val) do 
                append(dlt, splice(indent(12), line(v))) 
            end
        else
            for i = 1, #val-1, 2 do
                ddt = line(splice4(val[i], ' : ', val[i+1], ms102time(val[i+1])))
                append(dlt, splice(indent(12), ddt))
            end
        end
        append(dlt, splice(indent(8), ddClose))
    elseif #val == 1 then
        ddt = unesc(dtitl(splice3(bold(splice(proper(dl_title), perm)), ': ', val[1]:match('%w+'))))
        append(dlt, splice(indent(8), ddt))
    else
        ddt = unesc(dtitl(splice(bold(splice(proper(dl_title), perm)), ': Missing')))
        append(dlt, splice(indent(8), ddt))
    end
    append(dlt, splice(indent(4), dlClose))
    return table.concat(dlt, '\n')
end

--[[
    parm 1 : (string) Directory pathname (trailing: / is optional)
    parm 2 : (string) Value's filename
    return : (string) raw form of values, (string) 'owner' permissions
--]]
local function get_value (v_path, v_name)
    local p = path.join(v_path, v_name)
    local fd1 = io.open(p, 'r')
    local lst = fd1:read('*all')
    fd1:close()
    local perm
    fd1 = io.popen(splice('stat -c %A ', p), 'r')
    perm = fd1:read('*line')
    fd1:close()
    perm = splice3(' (', perm:sub(2,3), ')')
    return lst, perm
end

-- returns: serial, manufacturer's code
local function get_dinfo ()
    local fd1, l, a, cmd, ser, mfc
    local lt = {}
    -- try idme (in its various versions)
    fd1 = io.popen('idme 2>&1', 'r')
    for l in fd1:lines() do append(lt, l) end
    fd1:close()
    a = lt[#lt]:split()             -- 'Show' option is on last line
    if a[2]:lower() == 'shows' then
        cmd = ('idme %s 2>&1'):format(a[1])
        fd1 = io.popen(cmd, 'r')
        lt = {}
        for l in fd1:lines() do append(lt, l) end
        fd1:close()
        for _, v in pairs(lt) do
            a = v:split()
            if a[1] == 'serial:' then ser = a[2] end
            if a[1] == 'mfg:' then mfc = a[2] end
            if ser and mfg then break end
        end
    else
        return 'Error ', 'Error '
    end
    if not ser or #ser < 6 then ser = 'Error ' end
    if not mfc then mfc = 'Error ' end
    return ser, mfc
end

local function get_pretty ()
    local fd1 = io.open('/etc/prettyversion.txt', 'r')
    local txt 
    if fd1 then 
        txt = fd1:read('*line')
        fd1:close()
    else
        txt = 'Missing'
    end
    return txt
end

local function get_kernel ()
    local fd1 = io.popen('uname -rv', 'r')
    local l = fd1:read('*line')
    fd1:close()
    local release, version = l:match('^([%w%p]+)%s*#%d+%s*([%w%p%s]*)')
    return release, version
end

local function get_dtime ()
    local fd1, s
    fd1 = io.popen('date -R', 'r')
    s = fd1:read('*line')
    fd1:close()
    return s
end

local function set_desc (page)
    local serial, mcode, model, firmware, kernel, build
    
    serial, mcode = get_dinfo()
    serial = serial:sub(1, 6)
    if serial:sub(1,1):lower() == 'g' then
        model = ('%s-%s'):format(serial:sub(1,2), serial:sub(3))
    else
        model = ('%s-%s'):format(serial:sub(1,4), serial:sub(5))
    end
    firmware = get_pretty()
    kernel, build = get_kernel()
    append(page, splice(indent(4),  dlOpen))
    append(page, splice(indent(8),  dtitl(bold('Reporting Device'))))
    append(page, splice(indent(8),  ddOpen))
    append(page, splice(indent(12), line(splice('Model: ',    model))))
    append(page, splice(indent(12), line(splice('Mfg Code: ', mcode))))
    append(page, splice(indent(12), line(splice('Firmware: ', firmware))))
    append(page, splice(indent(12), line(splice('Kernel: ',   kernel))))
    append(page, splice(indent(12), line(splice('Build: ',    build))))
    append(page, splice(indent(8),  ddClose))
    append(page, splice(indent(4),  dlClose))
end

-- Get system key value of current governor
local fd1 = io.popen("kdb get system/driver/cpu/SYS_CPU_GOVERNOR 2>/dev/null", 'r')
local agt = fd1:read('*all'); fd1:close()
local elem = agt:split('/')

local tPath = {}
local section = ''
local tmp

if elem[#elem - 3] == 'cpu' then
    append(page, header)
    append(page, tostring(hdr1('System CPU Settings')))
    append(page, get_dtime())
    set_desc(page)
    
-- walk this part of the /sys/devices/system sub-tree
    append(page, tostring(hdr2('cpu')))
    section = 'cpu'
    elem[#elem - 2], elem[#elem - 1], elem[#elem] = nil, nil, nil
    tPath = table.concat(elem, '/')
    for root, dirs, files in dwalk(tPath, false, true) do
        if #files > 0 then
            if section ~= basename(root) then
                tmp = root:split('/')
                append(page, tostring(hdr3(splice3(tmp[#tmp -1], '; ', tmp[#tmp]))))
            end
            for _, name in pairs(files) do
                append(page, dl_string(name, get_value(root, name)))
            end
        end
    end
    append(page, footer)
    
    fd1 = io.open('/mnt/us/documents/cpu_report.txt', 'w')
    fd1:write(table.concat(page, '\n'))
    fd1:flush()
    fd1:close()
    os.exit(0)
else
    io.stderr:write("Unexpected directory structure.")
    os.exit(1)
end
