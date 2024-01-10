#!/bin/sh

# Adapted from
#   https://old.reddit.com/r/i3wm/comments/ry4n2v/any_recommended_drop_down_terminal_well_suited_to/
#   https://old.reddit.com/r/archlinux/comments/7czlx7/shell_script_need_help_to_create_dropdown/
# The idea is to support multiple terminals by passing the terminal as argument
# Works with xterm and urxvt. Untested with kitty or others

# BUGS:
# - the first time the terminal is launched it shows up as if it's another window (ie it will stack with other ones); calling hiding and showing won't fix it
# NOT A BUG, BUT NOT IDEAL:
# - drop down terminal has no setting/parameter to choose percentage of screen covered, currently it uses the whole screen
# - polybar gets hidden by terminal, to change this adapt the code with:
#     xprop -id $(xdo id -N Polybar) | grep '_NET_WM_STRUT(CARDINAL)'
# - unable to set a prefix to the window. I can either hardcode a static name or have no control over it (where window name updates as you change the pwd). I can change the name on terminal toggle but then wouldn't be able to update it when changing pwd. To further look into this:
#     xdotool getwindowname $(xdotool search --classname $DROPDOWN_NAME)
#     xdotool search --classname $DROPDOWN_NAME set_window --name "some new name"



DROPDOWN_NAME="quaketerm42" # instance name of the X resource/window

_show_term() {
  # do not cover polybar (but it is always 32px?)
  #i3-msg -q "[instance=\"$DROPDOWN_NAME\"] scratchpad show, [instance=\"$DROPDOWN_NAME\"] move window to position 0 px 31 px, [instance=\"$DROPDOWN_NAME\"] resize set 1920px 1049px"
  # show terminal full screen
  WIDTH=$(xrandr | grep '*' | awk '{print $1}' | cut -d "x" -f1)
  HEIGHT=$(xrandr | grep '*' | awk '{print $1}' | cut -d "x" -f2)
  i3-msg -q "[instance=\"$DROPDOWN_NAME\"] scratchpad show, [instance=\"$DROPDOWN_NAME\"] move window to position 0 px 0 px", [instance=\"$DROPDOWN_NAME\"] resize set ${WIDTH}px ${HEIGHT}px
  return $?
}

_hide_term() {
  i3-msg -q "[instance=\"$DROPDOWN_NAME\"] move scratchpad"
}

_launch_term() {
  if [ "$1" = "kitty" ]; then
    kitty --single-instance --class $DROPDOWN_NAME 1>/dev/null 2>/dev/null &
  elif [ "$1" = "urxvt" ]; then
    urxvt -name $DROPDOWN_NAME 1>/dev/null 2>/dev/null &
  #elif [ "$1" = "xterm" ]; then
  else
    # launch normal xterm:
    #xterm -name $DROPDOWN_NAME 1>/dev/null 2>/dev/null &
    # launch utf support xterm (normally we would pass -class UXTerm but that naming ends up dodging our .Xresources settings) with hardcoded window title:
    #xterm -u8 -name $DROPDOWN_NAME -xrm 'XTerm.vt100.allowTitleOps: false' -title $DROPDOWN_NAME 1>/dev/null 2>/dev/null &
    # launch utf support xterm (normally we would pass -class UXTerm but that naming ends up dodging our .Xresources settings):
    xterm -u8 -name $DROPDOWN_NAME 1>/dev/null 2>/dev/null &
  fi
  # [ -n "$2" ] && _hide_term || _show_term
}


if xlsclients -l | grep Instance | awk '{print $2}' | grep $DROPDOWN_NAME 1>/dev/null 2>/dev/null; then
  #echo "DEBUG: x terminal already exists... going to either hide or show it"
  if ! _show_term; then
    _hide_term
  fi
else
  #echo "DEBUG: no x terminal exists... going to launch one"
  _launch_term "$@"
fi
