#!/bin/bash
echo $spotify_user
if [ -z "$PULSE_COOKIE_DATA" ]
then
    echo -ne $(echo $PULSE_COOKIE_DATA | sed -e 's/../\\x&/g') >$HOME/pulse.cookie
    export PULSE_COOKIE=$HOME/pulse.cookie
fi

snapserver &
/usr/bin/mopidy -o mpd/hostname=0.0.0.0 -o http/hostname=0.0.0.0 -o spotify/username=$spotify_user -o spotify/password=$spotify_password -o spotify/client_id=$spotify_client_id -o spotify/client_secret=$spotify_client_secret -o youtube/enabled=false -o audio/output=‘audioresample ! audioconvert ! audio/x-raw,rate=48000,channels=2,format=S16LE ! wavenc ! filesink location=/tmp/snapfifo’
