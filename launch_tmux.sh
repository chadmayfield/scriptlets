#!/bin/bash

# tmux_launch.sh - launch tmux dev env

# INFO: to identify panes easily;
# Ctrl+B + Q (within tmux)
# --- or ---
# tmux display -pt "${TMUX_PANE:?}" '#{pane_index}'
# view panes: #{session_name}:#{window_index}.#{pane_index}

if [[ $OSTYPE =~ "linux" ]]; then

    # check hostnames and apply create env for each machine
    if [[ "$(hostname)" =~ "phobos" ]]; then
        # start a new 'main' session detached
        tmux new-session -s "main" -d -n "dev1"

        # set the status bar for this session
        #tmux set status-bg default
        #tmux set status-fg white
        #tmux set status-left '#[fg=green]#S'
        tmux set status-right '#[fg=red,bold]w#{window_index}.p#{pane_index} #[fg=default,nobold](#(whoami)@#h) %H:%M:%S %d-%b-%y'
        #tmux set status-right '#{session_name}:#{window_index}.#{pane_index} (#(ehoami)@#h) %H:%M:%S %d-%b-%y'
        #tmux set status-left-length 20
        tmux set status-right-length 80

        ######## create a new window: dev1 (dev1 environment)
        #tmux new-window -t main:0 -n "dev1"
        #tmux rename-window dev

        # split windows into panes
        tmux split-window -h
        tmux split-window -h
        #tmux select-layout even-horizontal
        tmux select-pane -t 1
        tmux split-window -v -p 50
        tmux select-pane -t 3 
        tmux split-window -v -p 50
        tmux select-pane -t 3
        tmux split-window -v -p 20

        # run these commands in created panes
        tmux send-keys -t 0 C-z 'cd ~/Code/' Enter
        tmux send-keys -t 1 C-z 'echo ssh fileserver' Enter
        tmux send-keys -t 2 C-z 'echo ssh fileserver' Enter
        tmux send-keys -t 3 C-z 'top' Enter
        tmux clock-mode -t 4
        tmux send-keys -t 5 C-z 'echo ssh file' Enter
        tmux select-pane -t main:0

        ######## create a new window: dev2 (dev2 environment)
        tmux new-window -t main:1 -n "dev2"

        # split windows into panes
        tmux split-window -h
        tmux split-window -h
        #tmux select-layout even-horizontal
        tmux select-pane -t 1
        tmux split-window -v -p 50
        tmux select-pane -t 3 
        tmux split-window -v -p 50

        # run these commands in created panes
        tmux send-keys -t 0 C-z 'cd ~/Code/ && ls' Enter
        tmux select-pane -t main:1

        ######## create a new window: k8s1 (work with k8s cluster)
        tmux new-window -t main:2 -n "k8s"

        # split windows into panes
        tmux split-window -h
        tmux select-layout even-horizontal
        tmux select-pane -t 0
        tmux split-window -v -p 50
        tmux select-pane -t 2 
        tmux split-window -v -p 50

        ######## create a new window: admin (for sysadmin-y things)
        tmux new-window -t main:3 -n "admin"

        # split windows into panes
        tmux split-window -h
        tmux split-window -h
        tmux select-layout even-horizontal
        tmux select-pane -t 0
        tmux split-window -v -p 50
        tmux select-pane -t 2
        tmux split-window -v -p 50
        tmux select-pane -t 4
        tmux split-window -v -p 50

        # run these commands in created panes
        tmux send-keys -t 0 C-z 'top' Enter
        tmux send-keys -t 1 C-z 'last' Enter
        tmux send-keys -t 2 C-z 'who' Enter
        tmux send-keys -t 3 C-z 'echo ssh fileserver' Enter
        tmux select-pane -t 0

        ######## create a new window: misc
        tmux new-window -t main:4 -n "misc"

        # split windows into panes
        tmux split-window -h
        tmux split-window -h
        tmux select-layout even-horizontal
        tmux select-pane -t 0
        tmux split-window -v -p 50
        tmux select-pane -t 2
        tmux split-window -v -p 50
        tmux select-pane -t 4
        tmux split-window -v -p 50

        # run these commands in created panes
        tmux send-keys -t 0 C-z 'echo command goes here' Enter
        tmux send-keys -t 1 C-z 'echo ssh remote server' Enter
        tmux select-pane -t 0

        # switch focus back to main window, pane 0
        tmux select-window -t 0
        tmux select-pane -t 0

        # attach to main session
        tmux -2 attach-session -t main
    elif [[ "$(hostname)" =~ (deimos|ISFL) ]]; then
        echo "TODO"  
    else
        echo "ERROR: Unknown host!"
    fi
elif [[ $OSTYPE =~ "darwin" ]]; then
    echo "Not implemented yet!"
    #pmset -g batt | grep [0-9][0-9]% | awk ‘NR==1{print$3}’ | cut -c 1–3
else
    # TODO: Add cygwin?
    echo "ERROR: Unknown \$OSTYPE, bailing out now!"
    exit 1
fi

#EOF
