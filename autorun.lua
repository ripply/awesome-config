run_once("nm-applet",nil,1)
-- -x fixes it working with QT applications such as skype
run_once("ibus-daemon","-d -x",1)
run_once("gnome-power-manager", nil, 1)
run_once("xfce4-power-manager","--no-daemon",1)
run_once("volti",nil,1)
run_once("jupiter",nil,1)
run_once("gnome-settings-daemon",nil,1)

run_once(browser,nil,1)
run_once("anki",nil,1)
run_once(im,nil,1)
run_once("rescuetime",nil,1)
-- fixes java gui issue by giving the window manager a name
--- otherwise it has no name and java does not draw correctly
-- http://awesome.naquadah.org/wiki/Problems_with_Java
awful.util.spawn_with_shell("wmname LG3D")

dropbox_path = os.getenv("HOME") .. "/.dropbox-dist/dropbox"
if file_exists(dropbox_path) then
   awful.util.spawn_with_shell( dropbox_path )
else
   awful.util.spawn_with_shell( "dropbox" )
end