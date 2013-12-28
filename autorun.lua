run_once("nm-applet")
-- -x fixes it working with QT applications such as skype
run_once("ibus-daemon","-d -x")
run_once("gnome-power-manager")
run_once("xfce4-power-manager","--no-daemon")
run_once("volti")
run_once("jupiter")
run_once("gnome-settings-daemon")

run_once(browser)
run_once("anki")
run_once(im)
run_once("rescuetime")

-- redshift changed their gtk gui commandline name
if command_exists("redshift-gtk") then -- newer version
   run_once("redshift-gtk")
elseif command_exists("gtk-redshift") then -- older version
   run_once("gtk-redshift")
end
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