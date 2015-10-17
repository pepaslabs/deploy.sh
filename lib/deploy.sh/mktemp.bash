# portable mktemp calls (works with BSD or GNU mktemp, e.g. OS X or Linux)
# thanks to http://unix.stackexchange.com/a/84980

function mktempfile()
{
    mktemp 2>/dev/null || mktemp -t "${_script_name}"
}

function mktempdir()
{
    mktemp -d 2>/dev/null || mktemp -d -t "${_script_name}"
}
