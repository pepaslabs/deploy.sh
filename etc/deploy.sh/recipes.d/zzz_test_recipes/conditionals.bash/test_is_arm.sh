if is_arm
then
    echo_step_color "${color_green}" "is an ARM chip."
else
    echo_step_color "${color_red}" "is not an ARM chip."
fi
