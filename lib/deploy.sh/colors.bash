# thanks to http://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# see also https://en.wikipedia.org/wiki/ANSI_escape_code#Colors

# the behavior of this script is modified by the following env vars:
#
# color_scheme
# * set to one of 'white_on_black', 'black_on_white', or 'no_color'
# * defaults to 'white_on_black'


# normal intensity colors
color_nblack='\033[0;30m'
color_nred='\033[0;31m'
color_ngreen='\033[0;32m'
color_nyellow='\033[0;33m'
color_nblue='\033[0;34m'
color_npurple='\033[0;35m'
color_ncyan='\033[0;36m'
color_nwhite='\033[0;37m'

# bright intensity colors
color_bblack='\033[1;30m'
color_bred='\033[1;31m'
color_bgreen='\033[1;32m'
color_byellow='\033[1;33m'
color_bblue='\033[1;34m'
color_bpurple='\033[1;35m'
color_bcyan='\033[1;36m'
color_bwhite='\033[1;37m'

color_off='\033[0m'
color_none=''

# dynamic color vars appropriate for xterms with black or white backgrounds.
cscheme="${color_scheme:-"white_on_black"}"
if [ "${cscheme}" == "black_on_white" ]
then
    color_black="${color_nblack}"
    color_red="${color_nred}"
    color_green="${color_ngreen}"
    color_yellow="${color_nyellow}"
    color_blue="${color_nblue}"
    color_purple="${color_npurple}"
    color_cyan="${color_ncyan}"
    color_white="${color_nwhite}"
elif [ "${cscheme}" == "white_on_black" ]
then
    color_black="${color_bblack}"
    color_red="${color_bred}"
    color_green="${color_bgreen}"
    color_yellow="${color_byellow}"
    color_blue="${color_bblue}"
    color_purple="${color_bpurple}"
    color_cyan="${color_bcyan}"
    color_white="${color_bwhite}"
else
    color_black="${color_none}"
    color_red="${color_none}"
    color_green="${color_none}"
    color_yellow="${color_none}"
    color_blue="${color_none}"
    color_purple="${color_none}"
    color_cyan="${color_none}"
    color_white="${color_none}"
    color_off=''
fi
