function cp_diff()
{
    local a="${1}"
    local b="${2}"
    if [ ! -e "${b}" ]
    then
        echo_step "Copying ${color_yellow}$( basename ${a} )${color_off} into $( dirname ${b} )."
        cp -a "${a}" "${b}"
    elif files_differ "${a}" "${b}"
    then
        echo_step_warning "Files differ: ${color_yellow}${a}${color_off} ${b}"
        if has_cmd colordiff
        then
            colordiff -urN "${a}" "${b}" || true
        else
            diff -urN "${a}" "${b}" || true
        fi
        cp -ai "${a}" "${b}"
    fi
}
