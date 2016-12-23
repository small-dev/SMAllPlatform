#! /bin/bash
launchMain() {
  now=$( date +"%H" )
  if [ "$now" -lt 20 ] && [ "$now" -gt 5 ]; then
    jolie main.ol
    sleep 3m
    launchMain
  else
    sleep 10m
  fi
}

sh get_dependencies.sh > dependencies.iol
launchMain