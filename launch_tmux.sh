#!/bin/bash

# launch_tmux.sh - launch my tmux dev env on different machines

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3
# date    : 02/12/2019

# ADDITIONAL INFO: 

# INFO: to identify panes easily;
# Ctrl+B + Q (within tmux)
# --- or ---
# tmux display -pt "${TMUX_PANE:?}" '#{pane_index}'
# view panes: #{session_name}:#{window_index}.#{pane_index}

if [[ $OSTYPE =~ "linux" ]]; then
    # get current IP address, to make sure we're on the correct network
    IP="$(ip -br -4 addr | grep UP | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")"

    # check hostnames and apply create env for each machine
    if [[ "$(hostname)" =~ "phobos" ]] && [[ "$IP" =~ "73.196" ]]; then
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
        tmux send-keys -t 1 C-z 'ssh file' Enter
        tmux send-keys -t 2 C-z 'ssh file' Enter
        tmux send-keys -t 3 C-z 'top' Enter
        tmux clock-mode -t 4
        tmux send-keys -t 5 C-z 'ssh file' Enter
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
        tmux send-keys -t 3 C-z 'echo ssh file' Enter
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

    # check hostnames and apply create env for each machine
    elif [[ "$(hostname)" =~ (deimos|ISFL) ]] && [[ "$IP" =~ "76.133" ]]; then
        # start a new 'main' session detached
        tmux new-session -s "main" -d -n "dev"

        # set the status bar for this session
        tmux set status-right '#[fg=red,bold]w#{window_index}.p#{pane_index} #[fg=default,nobold](#(whoami)@#h) %H:%M:%S %d-%b-%y'
        tmux set status-right-length 80

        ######## create a new window: dev (dev environment)
        # split windows into panes
        tmux split-window -h
        #tmux select-layout even-horizontal
        tmux select-pane -t 1
        tmux split-window -v -p 50

        # run these commands in created panes
        tmux send-keys -t 0 C-z 'cd ~/Code/' Enter
        tmux send-keys -t 1 C-z 'ssh file' Enter
        tmux send-keys -t 2 'if ! /usr/local/bin/sysinfo.sh; then curl -sSL https://git.io/fhQAQ | sudo bash; fi' Enter
        tmux select-pane -t main:0

        ######## create a new window: admin (for sysadmin-y things)
        tmux new-window -t main:1 -n "admin"

        # split windows into panes
        tmux split-window -h
        tmux select-layout even-horizontal
        tmux select-pane -t 0
        tmux split-window -v -p 50
        tmux select-pane -t 2
        tmux split-window -v -p 50

        # run these commands in created panes
        tmux send-keys -t 0 C-z 'ssh file' Enter
        tmux send-keys -t 1 C-z 'who' Enter
        tmux send-keys -t 2 C-z 'last' Enter
        tmux send-keys -t 3 'if ! /usr/local/bin/sysinfo.sh; then curl -sSL https://git.io/fhQAQ | sudo bash; fi' Enter
        tmux select-pane -t 0

        ######## create a new window: k8s1 (work with k8s cluster 1)
        tmux new-window -t main:2 -n "k8s1"

        # split windows into panes
        tmux split-window -h
        tmux select-layout even-horizontal
        tmux select-pane -t 0
        tmux split-window -v -p 50
        tmux select-pane -t 2 
        tmux split-window -v -p 50

        # run these commands in created panes
        #tmux send-keys -t 0 C-z 'ssh k8s-node1' Enter
        #tmux send-keys -t 1 C-z 'ssh k8s-node2' Enter
        #tmux send-keys -t 2 C-z 'ssh k8s-node3' Enter
        #tmux send-keys -t 3 C-z 'ssh k8s-node4' Enter
        #tmux select-pane -t 0

        ######## create a new window: k8s2 (work with k8s cluster 2)
        tmux new-window -t main:3 -n "k8s2"

        # split windows into panes
        tmux split-window -h
        tmux select-layout even-horizontal
        tmux select-pane -t 0
        tmux split-window -v -p 50
        tmux select-pane -t 2 
        tmux split-window -v -p 50

        # run these commands in created panes
        #tmux send-keys -t 0 C-z 'ssh n1' Enter
        #tmux send-keys -t 1 C-z 'ssh n2' Enter
        #tmux send-keys -t 2 C-z 'ssh n3' Enter
        #tmux send-keys -t 3 C-z 'ssh n4' Enter
        #tmux select-pane -t 0

        ######## create a new window: misc
        tmux new-window -t main:4 -n "misc"

        # split windows into panes
        tmux split-window -h
        tmux select-layout even-horizontal
        tmux select-pane -t 0
        tmux split-window -v -p 50
        tmux select-pane -t 2
        tmux split-window -v -p 50

        # run these commands in created panes
        tmux send-keys -t 0 C-z 'ssh file' Enter
        tmux select-pane -t 0

        # switch focus back to main window, pane 0
        tmux select-window -t 0
        tmux select-pane -t 0

        # attach to main session
        tmux -2 attach-session -t main
    else
        echo "ERROR: Not implemented (UNKNOWN HOST)!"
        exit 1
    fi
elif [[ $OSTYPE =~ "darwin" ]]; then
   
    # grab internal IPv4 address and check it
    IP="$(ifconfig en0 | grep 'inet ' | awk '{print $2}')"

    if [[ "$(hostname -s)" =~ "MBP" ]] && [[ "$IP" =~ "7.10" ]]; then
        # start a new 'main' session detached
        tmux new-session -s "main" -d -n "dev"

        # set the status bar for this session
        #pmset -g batt | grep [0-9][0-9]% | awk ‘NR==1{print$3}’ | cut -c 1–3
        tmux set status-right '#[fg=red,bold]w#{window_index}.p#{pane_index} #[fg=default,nobold](#(whoami)@#h) %H:%M:%S %d-%b-%y'
        tmux set status-right-length 80

        ######## create a new window: dev1 (dev1 environment)
        # split windows into panes
        tmux split-window -h
        #tmux select-layout even-horizontal
        tmux select-pane -t 1
        tmux split-window -v -p 50

        # run these commands in created panes
        tmux send-keys -t 0 C-z 'cd ~/Code/' Enter
        tmux send-keys -t 0 'if ! /usr/local/bin/sysinfo.sh; then curl -sSL https://git.io/fhQAQ | bash; fi' Enter
        tmux send-keys -t 1 C-z 'ssh file' Enter
        tmux send-keys -t 1 "ls" C-m
        tmux send-keys -t 2 C-z 'ssh file' Enter
        tmux send-keys -t 2 "uptime" C-m
        tmux select-pane -t main:0

        ######## create a new window: plex (plex environment)
        tmux new-window -t main:1 -n "plex"

        # split windows into panes
        tmux split-window -h
        #tmux select-layout even-horizontal
        tmux select-pane -t 1
        tmux split-window -v -p 50

        # run these commands in created panes
        tmux send-keys -t 0 C-z 'ssh plex' Enter
        tmux send-keys -t 0 "cd /mnt/plex/ && ls" C-m
        tmux send-keys -t 1 C-z 'ssh plex' Enter
        tmux send-keys -t 1 "cd /mnt/plex/ && ls" C-m
        tmux select-pane -t main:1

        ######## create a new window: transmission (transmission environment)
        tmux new-window -t main:2 -n "transmission"

        # split windows into panes
        tmux split-window -h
        #tmux select-layout even-horizontal
        tmux select-pane -t 1
        tmux split-window -v -p 50

        # run these commands in created panes
        tmux send-keys -t 0 C-z 'ssh transmission' Enter
        tmux send-keys -t 0 "cd ~/completed/ && ls" C-m
        tmux send-keys -t 1 C-z 'ssh transmission' Enter
        tmux send-keys -t 1 "cd ~/completed/" C-m
        tmux send-keys -t 2 C-z 'ssh transmission' Enter
        tmux send-keys -t 2 "dfh" C-m
        tmux select-pane -t main:2

        ######## create a new window: k8s (work with k8s cluster)
        tmux new-window -t main:3 -n "k8s"

        # split windows into panes
        tmux split-window -h
        tmux select-layout even-horizontal
        tmux select-pane -t 0
        tmux split-window -v -p 50
        tmux select-pane -t 2 
        tmux split-window -v -p 50
        tmux select-pane -t main:3

        # run these commands in created panes
        tmux send-keys -t 0 C-z 'ssh k8s-node1' Enter
        tmux send-keys -t 0 "kubectl get nodes && kubectl get po --all-namespaces" C-m
        tmux send-keys -t 1 C-z 'ssh k8s-node2' Enter
        tmux send-keys -t 2 C-z 'ssh k8s-node3' Enter
        tmux send-keys -t 3 C-z 'ssh k8s-node4' Enter

        ######## create a new window: misc
        tmux new-window -t main:4 -n "misc"

        # split windows into panes
        tmux split-window -h
        tmux select-layout even-horizontal
        tmux select-pane -t 1 
        tmux split-window -v -p 50
        tmux select-pane -t main:4

        # switch focus back to main window, pane 0
        tmux select-window -t 0
        tmux select-pane -t 0

        # attach to main session
        tmux -2 attach-session -t main
    else
        echo "Not implemented yet!"
        exit 1
    fi
else
    # TODO: Add cygwin?
    echo "ERROR: Unknown \$OSTYPE, bailing out now!"
    exit 1
fi

#EOF
