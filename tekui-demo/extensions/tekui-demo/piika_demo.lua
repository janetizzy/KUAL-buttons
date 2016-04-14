#!/usr/bin/lua -lesys
--
-- tekUI demo frontend by piika
--   ensure window title conforms to kindle naming convention
--   add a Close demo button to close demo
--
require "os"
local ui = require "tek.ui"

-- runs any of tekUi demos, demo file is passed as 1st arg

local demo = arg[1]
if demo == nil then
    print("no demo is passed.")
    os.exit()
elseif not demo:match("^demo_") then
    print(demo .. " is not supported.")
    os.exit()
end
print("running " .. demo)

local window
local app = ui.Application:new({
    ProgramName = "L:A_N:application_ID:tekUiDemo",       
    up = function(self) -- add a close demo
        local x, y, w, h = window.Drawable:getAttrs("xywh")
        print(x, y, w, h)
        local quitWindow = ui.PopupWindow:new { Top = y + h + 35, Height = 50,
          PopupWindow = true,
          Children = {
            ui.Button:new { Text = "Close demo",
                onClick = function(self)  
                    self.Application:quit()
                end
            }
          }
        } 
        ui.Application.connect(quitWindow) 
        self:addMember(quitWindow) 
        quitWindow:show()
    end
    })

print(app.ProgramName) 
local success, res = pcall(dofile, demo)
if success then                                                        
    window = res.Window
    -- ensure window title conforms to kindle naming convention
    window.Title = app.ProgramName 
    ui.Application.connect(window) 
    app:addMember(window) 
    window:setValue("Status", "show") 
    app:run()
else
    print(demo .. " fails")
end
    

