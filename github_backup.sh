#!/bin/bash

DATE=$(date +%Y-%m-%dT%H%M%S)

display_usage() {
  echo -e "\nUsage: ./github_backup.sh -d <backup directory>\n"
}

ENCRYPTED_TOKEN=ghub_token.gpg

# check token file exists
if [ ! -f "$ENCRYPTED_TOKEN" ]
then
  echo "$ENCRYPTED_TOKEN not found"
  exit 1
fi
  

# get backup directory if specified
if [ "$1" == '-d' ] && [ ! -z "$2" ]
then
  # check that directory exists
  if [ -d $2 ]
  then
    BACKUP_DIR=$2
  else
    echo "Cannot find $2"
    exit 1
  fi
else
  display_usage
  exit 1
fi

# get username and password
read -p 'username: ' GHUB_UNAME
read -sp 'password: ' GHUB_PASSWD


# token must be valid (i.e. not expired) on github
# gpg encryption password should be same as github password
GHUB_TOKEN=`gpg --no-symkey-cache --quiet -d --batch --passphrase \
$GHUB_PASSWD $ENCRYPTED_TOKEN 2>/dev/null`

# check password
echo $GHUB_UNAME_RESPONSE
if [ ! $GHUB_TOKEN ]
then
  echo 'Incorrect token password'
  exit 1
fi

# fetch user repos ssh_urls where owner is GHUB_UNAME
SSH_URLS=`curl --silent -u $GHUB_UNAME:$GHUB_TOKEN \
"https://api.github.com/user/repos" | grep -oe \
"git@github\.com:$GHUB_UNAME/.*\.git"`

# if there is no result, username may be wrong
if [ -z "$SSH_URLS" ]
then
  echo 'No url fetched. Check username is correct'
  exit 1
fi

# prepare temporary folder
mkdir -p /tmp/ghub_bck
cd /tmp/ghub_bck

# get number of repositories to clone
NUM_REPO=0
for SSH_URL in $SSH_URLS
do
  NUM_REPO=$(($NUM_REPO+1))
done

echo "cloning $NUM_REPO repositories into /tmp/ghub_bck"
COUNTER=1
for SSH_URL in $SSH_URLS
do
  echo "[ $COUNTER/$NUM_REPO ]"
  git clone $SSH_URL
  COUNTER=$(($COUNTER+1))
done

echo -n "making archive $DATE.tar.gz into $BACKUP_DIR..."
cd /tmp/ghub_bck
tar -czf $BACKUP_DIR/$DATE.tar.gz ./*
echo ' done'

echo -n 'cleaning up temporary files...'
rm -rf /tmp/ghub_bck
echo ' done'
