#!/bin/bash

snapserver &
echo "itse olet syönyt sen piirakan kuitenkin"
/usr/bin/mopidy "$@"
