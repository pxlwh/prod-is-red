# Copied to <host>:~/.config/fish/functions/fish_title.fish by bin/deploy-remote,
# with __HOST__ replaced by the host's name.
#
# This is the whole remote side: announce which box you are in the terminal
# title, so the local window rule can match it and paint the border.
function fish_title
    if set -q argv[1]; and test -n "$argv[1]"
        echo "__HOST__: $argv[1]"
    else
        echo "__HOST__:"(prompt_pwd)
    end
end
