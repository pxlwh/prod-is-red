#!/usr/bin/env fish
# Wire prod-is-red into ~/.config/. Idempotent, safe to re-run.
#
#   ssh.fish        -> ~/.config/fish/functions/   (symlink)
#   themes/*.conf   -> ~/.config/kitty/themes/     (symlink)
#   host-tints.conf -> ~/.config/hypr/             (COPIED, not linked)
#
# host-tints.conf is copied rather than symlinked on purpose: it lists your
# machines. Symlinking it would put your fleet inside a git checkout, so every
# host you add shows up as a repo diff and your infrastructure quietly becomes
# part of a repo you might one day publish. Your hosts are yours; the tool is
# the tool.

set -l repo (realpath (status dirname))
set -l fish_funcs $HOME/.config/fish/functions
set -l kitty_themes $HOME/.config/kitty/themes
set -l hypr $HOME/.config/hypr

mkdir -p $fish_funcs $kitty_themes $hypr

function _ln --argument-names src dst
    if test -L $dst; and test (readlink $dst) = $src
        echo "  [ok ]  $dst"
        return
    end
    if test -e $dst
        echo "  [skip] $dst exists and is not ours, leaving it alone"
        return
    end
    ln -s $src $dst
    and echo "  [new ]  $dst -> $src"
end

echo "Linking ssh wrapper..."
_ln $repo/ssh.fish $fish_funcs/ssh.fish

echo "Linking kitty themes..."
for f in $repo/themes/*.conf
    _ln $f $kitty_themes/(basename $f)
end

echo "Host registry..."
if test -f $hypr/host-tints.conf
    echo "  [ok ]  $hypr/host-tints.conf already exists, not touching it"
else
    cp $repo/host-tints.conf.example $hypr/host-tints.conf
    and echo "  [new ]  $hypr/host-tints.conf (copied from the example, go edit it)"
end

echo "Border rules..."
if grep -q 'ssh_tints' $hypr/windowrules.lua 2>/dev/null
    echo "  [ok ]  ssh_tints table found in windowrules.lua"
else
    echo "  [WARN]  no ssh_tints table in $hypr/windowrules.lua, so borders will not tint."
    echo "          Paste hyprland/windowrules.lua.example into it."
end

if type -q hyprctl
    hyprctl reload >/dev/null 2>&1; and echo "  [ok ]  hyprctl reload"
end

echo
echo "Next:"
echo "  1. edit ~/.config/hypr/host-tints.conf   (your hosts)"
echo "  2. paste hyprland/windowrules.lua.example into ~/.config/hypr/windowrules.lua"
echo "  3. bin/deploy-remote <host>              (fish remotes; bash: see README)"
