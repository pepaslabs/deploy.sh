function echo2()
{
    echo "${@}" >&2
}

function echo_step()
{
    echo_step_color "${color_cyan}" "${@}"
}

function echo_step_color()
{
    local color="${1}" ; shift
    echo -e "${color} * ${echo_step_component}: ${color_off}${@}"
}

function echo_step_ok()
{
    echo -e "${color_green} * OK (${echo_step_component}): ${color_off}${@}" >&2
}

function echo_step_warning()
{
    echo -e "${color_yellow} * WARNING (${echo_step_component}): ${color_off}${@}" >&2
}

function echo_step_error()
{
    echo -e "${color_red} * ERROR (${echo_step_component}): ${color_off}${@}" >&2
}
