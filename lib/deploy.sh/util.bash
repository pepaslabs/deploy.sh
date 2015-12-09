function link_bin()
{
    if [ -e ~/local/bin/"${1}" -a ! -L ~/local/bin/"${1}" ]
    then
        echo_step_error "Refusing to clobber ~/local/bin/${1}."
        exit 1
    fi
    ln -sf "$( pwd )/${1}" ~/local/bin/
}

