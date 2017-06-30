#!bin bash
#SUM detection script
#©2016 Patrick M. Womack - Niceville High School - womackp@blacksector.tech
#A special thanks to Jacob Salmela - None of this would have been possible without him.

#----------VARIABLES---------
# Capture date for storing in custom plist
currentDate=$(date "+%Y-%m-%d %H:%M:%S")

# Organization name (reverse-domain plist format)
orgName="org.choicit.ocsd"

#----------FUNCTIONS---------
#######################
function mountAndLoad()
{
/sbin/mount -uw /
# Loads daemons needed for networking in SUM
launchctl load /System/Library/LaunchDaemons/com.apple.configd.plist
sleep 5
#loads daemons needed for curl notifications
launchctl load -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
launchctl load /System/Library/LaunchDaemons/com.apple.securityd.plist
# Needed to send messages to the system log
launchctl load /System/Library/LaunchDaemons/com.apple.syslogd.plist
}

##########################
function notify
{
curl -d 'to=rootmail@nicevillehighschool.net&amp;toname=Destination&amp;subject=ALERT: SINGLE USER MODE ACCESSED&amp;text=Please check the logs on CHOICE-SRV-R. It will tell you the MAC address of the machine, you can then consult the spreadsheet to determine the correct Mac, and its location. Please do not reply, this email is unmonitored.&amp;from=rootmail@nicevillehighschool.net&amp;api_user=choicerootmailer&amp;api_key=Choice2016' https://api.sendgrid.com/api/mail.send.json
curl -d -X http://textbelt.com/text -d number=8505851744 -d "message=Single User Mode has been accessed, check the logs on CHOICE-SRV-R. Please do not reply, this number is unmonitored."
}
##########################
function setPromptCommand()
{
# Appends any commands entered into the syslog with the tag SUM-IDS
PROMPT_COMMAND='history -a;tail -n1 ~/.sh_history | logger -t SUM-IDS'
}

##########################
function logDateInPlist()
{
# Delete previous value if it exits
/usr/libexec/PlistBuddy -c "Print :SingleUserModeAccessedOn" /Library/Preferences/"$orgName".plist &>/dev/null
# If the last command exited with 0 (meaning the key exists)
if [ $? = 0 ];then
# Delete previous value and write in the updated date
/usr/libexec/PlistBuddy -c "Delete :SingleUserModeAccessedOn" /Library/Preferences/"$orgName".plist &>/dev/null
/usr/libexec/PlistBuddy -c "Add :SingleUserModeAccessedOn string '$currentDate'" /Library/Preferences/"$orgName".plist &>/dev/null
else
# Otherwise, create an entry with the current date
/usr/libexec/PlistBuddy -c "Add :SingleUserModeAccessedOn string '$currentDate'" /Library/Preferences/"$orgName".plist &>/dev/null
fi
}

####################
function networkalert
{
ifconfig en0 192.168.1.243
}


####################
function warnUser()
{
clear
echo "You Shouldn't be here."
afplay /.shared/alarm.mp3
}

#---------------------------------#
#---------------------------------#
#----------SCRIPT BEGINS----------#
#---------------------------------#
#---------------------------------#
if [ $TERM = "vt100" ];then
mountAndLoad
notify
setPromptCommand
logDateInPlist
networkalert
warnUser
fi