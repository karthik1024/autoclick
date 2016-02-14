#!/bin/bash

# Copyright 2016 Karthik Vijayraghavan.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.




# This program uses the xdotool program to send a mouse click whenever
# the mouse is moved. For some people who suffer from repetitive strain
# injury, such a tool might be beneficial.
 
# Time interval between checks when in the IDLE state.
IDLE_CHECK_INTERVAL=0.05

# Time interval between checks when in the MOVING state.
MOVING_CHECK_INTERVAL=0.2

# The minimum distance^2 mouse needs to move to go from
# IDLE to MOVING state and also from MOVING to DOCLICK state
THRESHOLD=25

# Left mouse buttom
LEFTBUTTON=1

# Initialize state machine
STATE="IDLE"
STIME=$IDLE_CHECK_INTERVAL
eval $(xdotool getmouselocation --shell) 
posx=$X
posy=$Y

# Loop forever
while [ 1 ]
do
    echo $STATE
    
    # Get current mouse location
    eval $(xdotool getmouselocation --shell)

    # If state is IDLE, check if mouse has moved enough to go to 
    # MOVING state.
    if [ "$STATE" = "IDLE" ]; then
	dist=$(((posx-X)*(posx-X) + (posy-Y)*(posy-Y)))
	if [ "$dist" -gt "$THRESHOLD" ]; then
	    STATE="MOVING"
	    posx=$X
	    posy=$Y
	    STIME=$MOVING_CHECK_INTERVAL
	fi  
    else
	# If state if MOVING, then check if mouse has come to a stop.
	# If mouse has stopped, click. Otherwise update position and 
	# continue.
	if [ "$STATE" = "MOVING" ]; then
	    dist=$(((posx-X)*(posx-X) + (posy-Y)*(posy-Y)))
	    if [ "$dist" -lt "$THRESHOLD" ]; then
		STATE="DOCLICK"
	    else
		posx=$X
		posy=$Y
	    fi
	else
	    # State is DOCLICK, so send a mouse click, and return
	    # to IDLE state.
	    xdotool click $LEFTBUTTON
	    STATE="IDLE"
	    posx=$X
	    posy=$Y
	    STIME=$IDLE_CHECK_INTERVAL
	fi
    fi
    
    # Sleep the appropriate amount to time before checking again.
    sleep $STIME
done
