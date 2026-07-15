function ssh --wraps='command ssh' --description 'ssh wrapper: per-host kitty palette swap'
    set -l tints_file ~/.config/hypr/host-tints.conf
    set -l theme_dir ~/.config/kitty/themes

    set -l host ""
    set -l theme ""
    if test -f $tints_file
        for arg in $argv
            for line in (string match -rv '^\s*(#|$)' < $tints_file)
                set -l fields (string split -n " " $line)
                if test (count $fields) -ge 2 -a "$fields[1]" = "$arg"
                    set host $fields[1]
                    set theme $fields[2]
                    break
                end
            end
            test -n "$host"; and break
        end
    end

    # Skip swap if not in kitty, no host matched, or stdout isn't a TTY.
    # The non-TTY guard is critical: when a tool (rsync, scp -e ssh, git over
    # ssh, mosh, or `ssh host 'cmd'` invocations) drives ssh, our `clear`
    # would write \033[2J\033[H to stdout — which becomes the data stream
    # going through the connection, corrupting whatever the caller is doing.
    if test -z "$host"; or test -z "$KITTY_PID"; or not isatty stdout
        command ssh $argv
        return
    end

    set -l theme_file $theme_dir/$theme.conf
    set -l default_theme $theme_dir/default.conf

    test -f $theme_file; and kitty @ set-colors --all $theme_file 2>/dev/null
    clear
    command ssh $argv
    set -l rc $status

    test -f $default_theme; and kitty @ set-colors --all $default_theme 2>/dev/null
    clear
    return $rc
end
