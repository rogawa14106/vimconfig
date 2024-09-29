# define constants
MSG_CONFIRM="Fully sync your current vim configuration with the main repository.\nLocal changes are permanently discarded.\nDo you want to continue?"
PROMPT_CONFIRM="yes/no:"

CMD_GIT_FETCH="git fetch origin main"
CMD_GIT_RESET="git reset --hard origin/main"

MSG_SYNC_SUCCESS="config sync success"
MSG_SYNC_ABORT="config sync aborted"

# confirm
echo -en "\e[33m${MSG_CONFIRM}\e[0m\n"
echo -en "\e[33m${PROMPT_CONFIRM} \e[0m"
read is_confirm

if [ $is_confirm == "yes" ]; then
    # sync config force
    echo -e "\e[32m-- ${CMD_GIT_FETCH}\e[0m"
    $CMD_GIT_FETCH
    echo -e "\e[32m-- ${CMD_GIT_RESET}\e[0m"
    $CMD_GIT_RESET
    echo -e "\e[32m-- ${CMD_GIT_RESET}\e[0m"
    echo ${MSG_SYNC_SUCCESS}
else
    # abort config sync
    echo ${MSG_SYNC_ABORT}
fi

exit
