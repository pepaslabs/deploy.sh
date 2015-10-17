echo_step "${color_yellow}needs_apt_noninstalled_package/test.sh${color_off} is running."

# install a package which is unlikely to exist on the user's system.
# likelyhood determined by http://popcon.debian.org/
needs.sh apt votca-csg-tutorials

# remove it so the test is still useful next time
echo_step "Removing ${color_yellow}votca-csg-tutorials${color_off}."
apt-get --yes remove votca-csg-tutorials
