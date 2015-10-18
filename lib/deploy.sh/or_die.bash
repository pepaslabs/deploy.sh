# or_dir.bash: functions to be used as guards in recipes.
# see https://github.com/pepaslabs/deploy.sh
#
# usage:
#
#     root_or_die
#
# each function should emit an echo_step_error and exit if the condition
# isn't met.


# meta

function die_for_x_only()
{
    local x="${1}"
    echo_step_error "This recipe is for ${x} only."
    exit 1
}


# user-related functions


function root_or_die()
{
    is_root || die_for_x_only "root"
}

function user_or_die()
{
    is_user || die_for_x_only "regular users"
}


# platform-related functions

function linux_or_die()
{
    is_linux || die_for_x_only "Linux"
}

function darwin_or_die()
{
    is_darwin || die_for_x_only "Darwin"
}

function debian_or_die()
{
    is_debian || die_for_x_only "Debian"
}

