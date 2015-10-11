function bashx()
{
    case "$-" in
        *x*)
            bash -x "${@}" ;;
        *)
            bash "${@}" ;;
    esac
    # thanks to http://unix.stackexchange.com/a/21929/136746
}
