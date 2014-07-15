-- ror.lua
-- This is the file goes in your ~/.config/awesome/ directory
-- It contains your table of 'run or raise' key bindings for aweror.lua
-- Table entry format: ["key"]={"function", "match string", "optional attribute to match"}
-- The "key" will be bound as "modkey + key".
-- The "function" is what gets run if no matching client windows are found.
-- Usual attributes are "class","instance", or "name". If no attribute is given it defaults to "class".
-- The "match string"  will match substrings.  So "Firefox" will match "blah Firefox blah"  
-- Use xprop to get this info from a window.  WM_CLASS(STRING) gives you "instance", "class".  WM_NAME(STRING) gives you the name of the selected window (usually something like the web page title for browsers, or the file name for emacs).

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

if filemanager == nil then
   filemanager = "nautilus"
end

filemanager_class = firstToUpper( filemanager )

if browser == nil then
   if command_exists( "gnome-www-browser" ) then
      browser = "gnome-www-browser"
   else
      browser = "firefox"
   end
end

browser_class = firstToUpper( browser )

if editor == nil then
   editor = "emacsclient -a emacs -n -c"
end

if string.find(editor,"emacs") then
   editor_class = "Emacs"
else
   editor_class = firstToUpper( browser )
end

if im == nil then
   im = "skype"
end

im_class = firstToUpper( im )

if terminal == nil then
   terminal = "xterm"
end

terminal_class = firstToUpper( terminal )

music_class = firstToUpper( music )

table5={
   ["e"]={"emacsclient -a emacs -n -c","Emacs"}, 
   ["q"]={filemanager, filemanager_class},
   ["w"]={browser, browser_class},
   ["a"]={"anki", "Anki"},
   ["t"]={music, music_class}, 
   ["F2"]={music, music_class},
   -- ["v"]={"firefox -new-window 'http://www.evernote.com/Home.action?login=true#v=l&so=mn'","Evernote", "name"}, 
   -- ["g"]={"firefox -new-window 'http://mail.google.com/mail/'","Gmail","name"}, 
   -- ["x"]={"xterm","xterm", "instance"}, 
   -- ["f"]={"xterm -name mcTerm -e mc -d","mcTerm", "instance"}, 
   -- ["s"]={"xterm -name rootTerm -cr red -title rootTerm -e su","rootTerm", "instance"}, 
   -- ["t"]={"xterm -name htopTerm -e htop","htopTerm","instance"}, 
   -- ["b"]={"xterm -name rtorrentTerm -e rtorrent","rtorrentTerm","instance"}, 
   -- ["z"]={"xterm -name mocpTerm -e mocp","mocpTerm", "instance"} 
   ["s"]={im, im_class},
   -- ["d"]={terminal, terminal_class},
   ["c"]={"virtualbox", "VirtualBox"}
}