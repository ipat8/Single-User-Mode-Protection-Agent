#!/bin/bash
# A GUI installer for the SUM script, V1 is built in zenity, because I'm lazy.

org="$(zenity --forms --title="Set FQDN" --text="What is your Organization's FQDN?" --add-entry="FQDN:")"

sendto="$(zenity --forms --title="Notification Setup" --text="Where would you like to receve alert emails?" --add-entry="Email Address for Notifications:")"

zenity --question --title="Setup SMTP" --text="Would you like to use your own SMTP server?" --ok-label="Yes" --cancel-label="No, use a public one"
  if [ $? = 0 ]
    then
      sendfrom="$(zenity --forms --title="Setup SMTP" --text="Where should we send alert emails from?.
      The server must support cURL." --add-entry="SMTP Server:")"
    else
    zenity --info --title="Setup SMTP" --text="We will use the public SMTP server provided by BST."
    sendfrom=smtp.public.blacksector.tech
  fi

srvname="$(zenity --forms --title="Server Information" --text="What is the name of the server that will be dectecting alerts?" --add-entry="Server name (NOT FQDN):")"

zenity --question --title="Mobile Alerts Setup" --text="Would you like to setup mobile alerts?" --ok-label="Yes" --cancel-label="No"
######I'd like to add the ability to have infinate numbers eventually
  if [ $? = 0 ]
    then
      pnumberuser="$(zenity --forms --title="Mobile Alerts Setup" --text="What is the phone number that you'd like to be notified on?" --add-entry="Phone Number:")"
      pnumber1nd="${pnumberuser//-}"
      pnumber1ns="${pnumber1nd// }"
      pnumber1p1="${pnumber1ns//(}"
      pnumber1="${pnumber1p1//)}"
      mobilealerts="$(curl -d -X http://textbelt.com/text -d number=$pnumber1 -d "message=Single User Mode has been accessed, check the logs on $srvname. Please do not reply, this number is unmonitored.")"
    else
    zenity --info --title="Mobile Alerts Setup" --text="Ok, we'll disable mobile alerts"
    mobilealerts="####Mobile Alerts Were Disabled"
  fi
