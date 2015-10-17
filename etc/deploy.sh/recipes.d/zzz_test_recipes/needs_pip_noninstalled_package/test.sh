echo_step "${color_yellow}needs_pip_noninstalled_package/test.sh${color_off} is running."

# install a package which is unlikely to exist on the user's system.
needs.sh pip oroboros

# remove it so the test is still useful next time
echo_step "Removing ${color_yellow}oroboros${color_off}."
pip uninstall oroboros
