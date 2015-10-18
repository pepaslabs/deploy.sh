# conditionals.bash: functions to be used in bash "if" statements.
# see https://github.com/pepaslabs/deploy.sh
#
# usage:
#
#     if ! is_root ; then echo "you aren't root" ; fi
#
# each function should produce no output and return 0 (true) or 1 (false).


# user-related functions

function is_root()
{
    [ "$( whoami )" == "root" ]
}

function is_user()
{
    [ "$( whoami )" != "root" ]
}


# platform-related functions

function is_linux()
{
    [ "$( uname )" == "Linux" ]
}

function is_darwin()
{
    [ "$( uname )" == "Darwin" ]
}

function is_debian()
{
    [ -e /etc/debian_version ]
    # see also http://unix.stackexchange.com/questions/29981/how-can-i-tell-whether-a-build-is-debian-based
    # see also http://stackoverflow.com/questions/394230/detect-the-os-from-a-bash-script/3792848#3792848
}


# command-related functions

function has_cmd()
{
	local cmd="${1}"
	which "${cmd}" >/dev/null 2>&1
}


# file-related functions

function files_differ()
{
    local a="${1}"
    local b="${2}"

    if [ ! -e "${a}" ] ; then exit 117 ; fi
    if [ ! -e "${b}" ] ; then return 0 ; fi

    if diff "${a}" "${b}" >/dev/null 2>&1
    then
        return 1
    else
        return 0
    fi
}
