prompt_Yn()
{
    local message="${1}"

    echo -e -n "${color_yellow} * PROMPT (${echo_step_component}): ${color_off}${@} [Y/n]: " >&2

    read yn
    case $yn in
        y|Y|yes|Yes|YES|'') return 0 ;;
        *) return 1 ;;
    esac
    # thanks to http://stackoverflow.com/a/226724
}

prompt_yN()
{
    local message="${1}"

    echo -e -n "${color_yellow} * PROMPT (${echo_step_component}): ${color_off}${@} [y/N]: " >&2

    read yn
    case $yn in
        y|Y|yes|Yes|YES) return 0 ;;
        *) return 1 ;;
    esac
    # thanks to http://stackoverflow.com/a/226724
}

