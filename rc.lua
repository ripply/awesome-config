-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("helpers") -- From https://github.com/tony/awesome-config

-- Load Debian menu entries
require("debian.menu")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")
-- beautiful.init(awful.util.getdir("config") .. "/theme.lua")

home = os.getenv("HOME")

-- {{{ Desktop shell + File manager + Browser configuration

if command_exists("xfdesktop") and command_exists("pcmanfm") then
  desktop_shell = "xfdesktop"
  desktop_shell_args = ""
  filemanager = "pcmanfm"
elseif command_exists("nautilus") then
  desktop_shell = "nautilus"
  desktop_shell_args = "-n"
  filemanager = desktop_shell
else
  filemanager = os.getenv("FILEMANAGER")
  desktop_shell = ""
end



if command_exists("google-chrome") then
 browser = "google-chrome"
elseif command_exists("chromium-browser") then
 browser = "chromium-browser"
elseif command_exists("gnome-www-browser") then
  browser = "gnome-www-browser"
else
  browser = os.getenv("BROWSER")
  if browser == nil then
    browser = "firefox"
  end
end

if command_exists("rhythmbox") then
  music = "rhythmbox"
elseif command_exists("audacious") then
  music = "audacious"
else
  music = ""
end

if command_exists("skype") then
  im = "skype"
end

-- }}}

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
-- filemanager = os.getenv("FILEMANAGER") or "pcmanfm" -- "Thunar" -- "pcmanfm"
editor = os.getenv("EDITOR")
if editor == nil then
   if command_exists("emacs") then
     editor = "emacs"
   elseif command_exists("gvim") then
     editor = "gvim"
   elseif command_exists("vim") then
     editor = "vim"
   end
end

require_safe("personal")

editor_cmd = editor

-- dont use terminal if emacs or gvim; its annoying
if string.find(editor_cmd,"emacs") or string.find(editor_cmd,"gvim") then
   editor_cmd = editor
else
   editor_cmd = terminal .. " -e " .. editor
end

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

 -- {{{ Tags
 -- Define a tag table which will hold all screen tags.
 tags = {
   names  = { "main", "www", "skype", "cpp", "office", "im", 7, 8, 9 },
   layout = { layouts[1], layouts[2], layouts[2], layouts[2], layouts[6],
              layouts[9], layouts[3], layouts[3], layouts[2]
 }}
 for s = 1, screen.count() do
     -- Each screen has its own tag table.
     tags[s] = awful.tag(tags.names, s, tags.layout)
 end
 -- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

if file_exists( home .. "/Dropbox" ) then
  dropbox_folder = home .. "/Dropbox"
else
  dropbox_folder = ""
end

mymainmenu = awful.menu({ items = { { "Awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "Open Terminal", terminal },
				    { "File Manager", filemanager  },
				    { "Dropbox", filemanager .. " " .. dropbox_folder },
                                    { "Audacious", "audacious" },
                                    { "Suspend", "sudo pm-suspend" },
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Volume widget
-- http://awesome.naquadah.org/wiki/Farhavens_volume_widget#Farhavens_mod

 function volume (mode, widget)
     local cardid  = 0
     local channel = "Master"
     if mode == "update" then
         local status = io.popen("amixer -c " .. cardid .. " -- sget " .. channel):read("*all")
         
         local volume = tonumber(string.match(status, "(%d?%d?%d)%%"))
 
         status = string.match(status, "%[(o[^%]]*)%]")
 
         local color = "#FF0000"
         if status ~= nil then
           if string.find(status, "on", 1, true) then
             color = "#00FF00"
           end

           status = ""
           for i = 1, math.floor(volume / 10) do
             status = status .. "|"
           end
           for i = math.floor(volume / 10) + 1, 10 do
             status = status .. "-"
           end
           status = "-[" ..status .. "]+"
           widget.text = "<span color=\"" .. color .. "\">" .. status .. "</span>|"
         end
     elseif mode == "up" then
         os.execute("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%+")
         volume("update", widget)
     elseif mode == "down" then
         os.execute("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%-")
         volume("update", widget)
     else
         -- os.execute("amixer -c " .. cardid .. " sset " .. channel .. " toggle")
         os.execute("amixer -D pulse set " .. channel .. " toggle")
         volume("update", widget)
     end
 end

tb_volume = widget({ type = "textbox", name = "tb_volume", align = "right" })
tb_volume:buttons({
	button({ }, 4, function () volume("up", tb_volume) end),
	button({ }, 5, function () volume("down", tb_volume) end),
	button({ }, 1, function () volume("mute", tb_volume) end)
})
volume("update", tb_volume)

awful.hooks.timer.register(10, function () volume("update", tb_volume) end)

-- end volume widget

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        tb_volume,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, "Shift"   }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Shift"   }, "e", function () awful.util.spawn(filemanager) end),
--    awful.key({ modkey, "Shift"   }, "e", function () awful.util.spawn("nautilus") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey }, "r",      function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "z",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    -- all minimized clients are restored 
    awful.key({ modkey, "Shift"   }, "n", 
        function()
            local tag = awful.tag.selected()
                for i=1, #tag:clients() do
                    tag:clients()[i].minimized=false
                    tag:clients()[i]:redraw()
            end
        end),

    awful.key({ modkey, "Control" }, "w", function () awful.util.spawn(awful.util.getdir("config") .. "/dl_random_wallpaper.sh", false) end),


    -- volumn keys
    awful.key({ modkey, }, "F12",function () volume("up", tb_volume) end), 
    awful.key({}, "#123", function () volume("up", tb_volume) end),
    awful.key({ modkey, }, "F11", function  () volume("down", tb_volume) end),
    awful.key({}, "#122", function  () volume("down", tb_volume) end),
    awful.key({ modkey, }, "F10", function () awful.util.spawn("amixer -q sset Master toggle", false) end),
    awful.key({}, "#121", function () awful.util.spawn("amixer -q sset Master toggle", false) end),
    awful.key({ modkey, "Control" }, "z", function () awful.util.spawn_with_shell("~/.config/awesome/musicplayback.sh prev", false) end),
    awful.key({ modkey, "Control" }, "v", function () awful.util.spawn_with_shell("~/.config/awesome/musicplayback.sh next", false) end),
    -- awful.key({ modkey, "Control" }, "x", function () awful.util.spawn_with_shell("~/.config/awesome/musicplayback.sh play", false) end),
    awful.key({ modkey, "Control" }, "c", function () awful.util.spawn_with_shell("~/.config/awesome/musicplayback.sh stop", false) end),
    awful.key({ modkey, "Control" }, "F1", function () awful.util.spawn("sudo cpufreq-set -g conservative", false) end),
    awful.key({ modkey, "Control" }, "F2", function () awful.util.spawn("sudo cpufreq-set -g ondemand", false) end),
    --awful.key({ modkey, "Control" }, "F1",function {} awful.util.spawn("sudo cpufreq-set -g conservative", false) end),
    --awful.key({ modkey, "Control" }, "F2",function {} awful.util.spawn("sudo cpufreq-set -g ondemand", false) end),
   
    -- media control keys; prev, next, play/pause etc
    awful.key({ modkey, }, "F1", function () awful.util.spawn_with_shell("~/.config/awesome/musicplayback.sh prev", false) end),
    awful.key({ modkey, }, "F3", function () awful.util.spawn_with_shell("~/.config/awesome/musicplayback.sh play", false) end),
    awful.key({ modkey, }, "F4", function () awful.util.spawn_with_shell("~/.config/awesome/musicplayback.sh next", false) end),

    -- Toggle titlebar visibility
    awful.key({ modkey, "Shift" }, "t", function (c)
       if   c.titlebar then awful.titlebar.remove(c)
       else awful.titlebar.add(c, { modkey = modkey }) end
    end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

-- load the 'run or raise' function
local ror = require("aweror")

-- generate and add the 'run or raise' key bindings to the globalkeys table
globalkeys = awful.util.table.join(globalkeys, ror.genkeys(modkey))

-- root.keys(globalkeys)

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- Use xprop to get this info

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys	 = clientkeys,
		      -- Remove gaps between windows
		     size_hints_honor = false,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true },
      callback = awful.titlebar.add },
    -- Set Firefox to always map on tags number 2 of screen 1.
--    { rule = { class = "Firefox" },
--      properties = { tag = tags[mouse.screen][2] } },
--    { rule = { class = "Firefox", instance = "Dialog" }, callback = function(c) awful.client.movetotag(tags[mouse.screen][awful.tag.getidx()], c) end},
    { rule = { class = "Gnome-www-browser" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Gnome-www-browser", instance = "Dialog" }, callback = function(c) awful.client.movetotag(tags[mouse.screen][awful.tag.getidx()], c) end},
-- Firefox fullscreen flash
    { rule = { instance = "plugin-container" },
      properties = { floating = true, fullscreen = true } },
-- Chrome fullscreen flash
    { rule = { instance = "exe" },
      properties = { floating = true, fullscreen = true } },
    { rule = { class = "Chromium-browser" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Anki" },
      properties = { tag = tags[1][7] } },
    { rule = { class = "VirtualBox" },
      properties = { tag = tags[1][7] } },
    -- deadbeaf is a music player
    { rule = { class = "Deadbeef" },
      properties = { tag = tags[screen.count()][9] } },
    { rule = { class = "Rhythmbox" },
      properties = { tag = tags[screen.count()][4] } },
    { rule = { class = "Audacious" },
      properties = { tag = tags[screen.count()][4] } },
    { rule = { class = "Skype" },
      properties = { tag = tags[mouse.screen][3] } ,
      callback = awful.client.setslave },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][6] } },
    { rule = { class = "Eclipse" },
      properties = { tag = tags[mouse.screen][4] } },
    { rule = { class = "Transmission" },
      properties = { tag = tags[screen.count()][7] } },
    { rule = { class = "Xchat" },
      properties = { tag = tags[screen.count()][3] } },
    { rule = { instance = "Download" },
      properties = { floating = true } },

    { rule = { name = "livewallpaper" },
      properties = { sticky = true } },
    { rule = { name = "Desktop" },
      properties = { sticky = true } },
    -- Set Xterm to multiple tags on screen 1
    -- { rule = { class = "X-terminal-emulator" }, callback = function(c) c:tags({tags[1][5], tags[1][6]}) end},

    -- Pidgin's buddy list
    -- from http://stackoverflow.com/questions/5120399/setting-windows-layout-for-a-specific-application-in-awesome-wm
    { rule = { class = "Pidgin", role = "buddy_list" },
    properties = {switchtotag = true, floating=true,
                  maximized_vertical=true, maximized_horizontal=false },
    callback = function (c)
        local cl_width = 250    -- width of buddy list window
        local def_left = true   -- default placement. note: you have to restart
                                -- pidgin for changes to take effect

        local scr_area = screen[c.screen].workarea
        local cl_strut = c:struts()
        local geometry = nil

        -- adjust scr_area for this client's struts
        if cl_strut ~= nil then
            if cl_strut.left ~= nil and cl_strut.left > 0 then
                geometry = {x=scr_area.x-cl_strut.left, y=scr_area.y,
                            width=cl_strut.left}
            elseif cl_strut.right ~= nil and cl_strut.right > 0 then
                geometry = {x=scr_area.x+scr_area.width, y=scr_area.y,
                            width=cl_strut.right}
            end
        end
        -- scr_area is unaffected, so we can use the naive coordinates
        if geometry == nil then
            if def_left then
                c:struts({left=cl_width, right=0})
                geometry = {x=scr_area.x, y=scr_area.y,
                            width=cl_width}
            else
                c:struts({right=cl_width, left=0})
                geometry = {x=scr_area.x+scr_area.width-cl_width, y=scr_area.y,
                            width=cl_width}
            end
        end
        c:geometry(geometry)
    end },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- FIXME
-- hooks
function hook_manage(c)
    -- return program name
    function program(p)
        return c.class:lower():find(p)
    end
    if program("chromium-browser") then
        awful.client.movetotag("www")
    end
    if program("x-terminal-emulator") then
        awful.client.movetotag("7")
    end
end

require_safe('autorun')
