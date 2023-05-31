#!/bin/bash

# !!! IMPORTANT
# Edit this variableas change .dotlist location
USER=khronos
DOTLIST="/home/${USER}/.dotlist"


#-FILE-STRUCTURE----------------------------------------------------------------------|
#
#
#   dotfiles/
#       portage/
#           make.conf
#           package.use/
#               custom-useflags
#               00cpu-flags
#               ...
#       .vimrc
#       crontab
#       ...
#
#
#-PRACTICES---------------------------------------------------------------------------|
#	- files to copy to dotfiles/ directory are taken from a separate file -> .dotlist
#   - first line in dotlist must be absolute filepath to dotfiles/ directory
#   - logs in color
#-VARIABLES---------------------------------------------------------------------------|


# paths
read -r DOTFILES_DIR < "$DOTLIST"

# colors
COLOR_END="\e[0m"
LIGHT_WHITE_COLOR="\e[37;1m"
LIGHT_RED_COLOR="\e[31;1m"
DARK_RED_COLOR="\e[31m"
LIGHT_GREEN_COLOR="\e[32;1m"
DARK_GREEN_COLOR="\e[32m"
LIGHT_YELLOW_COLOR="\e[33;1m"
DARK_YELLOW_COLOR="\e[33m"


#-FUNCTIONS---------------------------------------------------------------------------|
#
#-log-function------------------------------------------------------------------------|
#
# USAGE:
# -     log error "${file} file doesn't exist"
# -     log update "${file} file has been updated"
# -     log info "${file} file has been created"
#
function log {
    local state="$1"    # states: update,info,error
    local msg="$2"
    local msg_color="$LIGHT_WHITE_COLOR"
    local prefix=""


    # set prefix based on state
    if [ "$state" == "update" ]; then
        prefix="[ ${LIGHT_GREEN_COLOR}UPDATE${COLOR_END} ] "
    elif [ "$state" == "info" ]; then
        prefix="[   ${LIGHT_YELLOW_COLOR}INFO${COLOR_END} ] "
    elif [ "$state" == "error" ]; then
        prefix="[  ${LIGHT_RED_COLOR}ERROR${COLOR_END} ] "
    else
        prefix="[ ${LIGHT_RED_COLOR}FATAL STATE ERROR${COLOR_END} ] "
    fi

    # display message
    msg="${msg_color}${msg}${COLOR_END}"
    echo -e "${prefix}${msg}"
}
#-generate-function------------------------------------------------------------------|
#
# USAGE:
# -     generate file "/home/khronos/.vimrc" ".vimrc"
# -     generate dir "/etc/portage/package.use" "portage/package.use/"
#
function generate {
    local src_path="$2"                                     # Second Parameter: absolute path to source file/directory
    local dot_path="$3"                                     # Third Parameter:  relative path to file/directory in dotfiles directory
    local dot_path_abs="${DOTFILES_DIR}/${dot_path}"        # absolute path to file/directory in dotfiles directory

    # if First Parameter is "file" then generate file
    if [ "$1" == file ]; then
        # if dot file doesn't exist -> create it
        if [ ! -e "$dot_path_abs" ]; then
            log error "${dot_path} file doesn't exist"
            touch "$dot_path_abs"
            log info "${dot_path} file has been created"
        fi
        # if dot file and src file have different contents -> update dot file
        if ! cmp -s "$src_path" "$dot_path_abs"; then
            cp "$src_path" "$dot_path_abs"
            log update "${dot_path} file has been updated"
        fi
    # if First Parameter is "directory" or "dir" then generate directory
    elif [[ "$1" == "directory" || "$1" == "dir" ]]; then
        # if dot directory doesn't exist -> create it
        if [ ! -d "$dot_path_abs" ]; then
            log error "${dot_path} directory doesn't exist"
            mkdir -p "$dot_path_abs"
            log info "${dot_path} directory has been created"
        fi
        # if dotdir and og_dir have different contents -> update dotdir
        if ! diff -r "$src_path" "$dot_path_abs" > /dev/null; then
            cp -r "$src_path"/* "$dot_path_abs"
            log update "${dot_path} directory has been updated"
        fi
    else
        echo "Something went very wrong"
    fi
}


#-MAIN_FUNCTION----------------------------------------------------------------------|
function main {
    # check if dotfiles directory exists 
    if [ ! -d $DOTFILES_DIR ]; then
	    log error "dotfiles directory doesn't exist"
        mkdir $DOTFILES_DIR
        log info "dotfiles directory has been created"
    fi

    # iterate through each line starting with 2nd
    tail -n +2 "$DOTLIST" | while IFS= read -r line
    do
        type=$(echo $line | awk '{print $1}')
        src=$(echo $line | awk '{print $2}')
        dest=$(echo $line | awk '{print $3}')
        generate "$type" "$src" "$dest"
    done
}

main
