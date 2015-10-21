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

function die_x_for_y_only()
{
    local x="${1}"
    local y="${2}"
    echo_step_error "This ${x} is for ${y} only."
    exit 1
}

function die_recipe_for_x_only()
{
    die_x_for_y_only "recipe" "${1}"
}


# user-related functions


function root_or_die()
{
    is_root || die_recipe_for_x_only "root"
}

function user_or_die()
{
    is_user || die_recipe_for_x_only "regular users"
}


# platform-related functions

function linux_or_die()
{
    is_linux || die_recipe_for_x_only "Linux"
}

function darwin_or_die()
{
    is_darwin || die_recipe_for_x_only "Darwin"
}

function debian_or_die()
{
    is_debian || die_recipe_for_x_only "Debian"
}

