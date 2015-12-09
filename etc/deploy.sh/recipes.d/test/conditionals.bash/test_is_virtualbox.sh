if is_virtualbox
then
    echo_step_color "${color_green}" "is a VirtualBox VM."
else
    echo_step_color "${color_red}" "is not a VirtualBox VM."
fi
