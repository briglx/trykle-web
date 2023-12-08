# shellcheck shell=bash
# Definition of common subroutines
load_env(){
    local env_file="$1"

    if [ -z "$env_file" ]
    then
        echo "ENV_FILE is required" >&2
        return 1
    fi

    if [ -f "$env_file" ]; then
        [ -f "${env_file}" ] && while IFS= read -r line; do [[ $line =~ ^[^#]*= ]] && eval "export $line"; done < "$env_file"
    else
        echo "ENV_FILE not found" >&2
        return 1
    fi
}
