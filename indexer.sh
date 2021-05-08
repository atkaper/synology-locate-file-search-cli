#!/bin/bash

# simple script with endless-loop, sleeping till 00:00 hours, and running a re-index then

echo "$( date ) start"
while true
do
   SLEEP_TILL_MIDNIGHT_SECONDS=$(($(date -d "$(date +00:00-24:00)" +%s)-$(date +%s)))
   echo "$( date ) Sleeping for $SLEEP_TILL_MIDNIGHT_SECONDS seconds to wait for next midnight..."
   sleep $SLEEP_TILL_MIDNIGHT_SECONDS

   echo "$( date ) start indexing"
   ./updatedb.sh || true
   echo "$( date ) indexing done"
done

