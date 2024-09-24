confirm_prompt="Fully sync your current vim configuration with the main repository.\nLocal changes are permanently discarded.\nDo you want to continue? yes/no:"
echo -en $confirm_prompt" "
read is_confirm
if [ $is_confirm == "yes" ]; then
    git fetch origin main
    git reset --hard origin/main
else
    echo "aborted."
fi
exit
