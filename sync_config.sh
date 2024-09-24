# define constants
CONFIRM_PROMPT="Fully sync your current vim configuration with the main repository.\nLocal changes are permanently discarded.\nDo you want to continue? yes/no:"
GIT_CMD_FEATCH="git fetch origin main"
GIT_CMD_RESET="git reset --hard origin/main"

# confirm
echo -en "\e[33m$CONFIRM_PROMPT \e[0m"
read is_confirm

if [ $is_confirm == "yes" ]; then
    # sync force
    echo -e "\e[32m-- ${GIT_CMD_FEATCH}\e[0m"
    $GIT_CMD_FEATCH
    echo -e "\e[32m-- ${GIT_CMD_RESET}\e[0m"
    $GIT_CMD_RESET
else
    # abort
    echo "aborted."
fi

exit
