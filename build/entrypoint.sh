#!/bin/ash

#Remove all samba users
rm -rf /var/lib/samba/private/* 2> /dev/null
grep '/samba/' /etc/passwd | cut -d':' -f1 | xargs -r -n1 deluser

#Create users
#USERS='name1|password1|[folder1][|uid1][|gid1] name2|password2|[folder2][|uid2][|gid2]'
#may be:
# user|password foo|bar|/home/foo
#OR
# user|password|/home/user/dir|10000
#OR
# user|password|/home/user/dir|10000|10000
#OR
# user|password||10000|82

#Default user 'samba' with password 'samba'

if [ -z "$USERS" ]; then
  USERS="samba|samba"
fi

for i in $USERS ; do
  NAME=$(echo $i | cut -d'|' -f1)
  GROUP=$NAME
  PASS=$(echo $i | cut -d'|' -f2)
  FOLDER=$(echo $i | cut -d'|' -f3)
  UID=$(echo $i | cut -d'|' -f4)
  # Add group handling
  GID=$(echo $i | cut -d'|' -f5)

  if [ -z "$FOLDER" ]; then
    FOLDER="/samba/$NAME"
  fi

  if [ ! -z "$UID" ]; then
    UID_OPT="-u $UID"
    if [ -z "$GID" ]; then
      GID=$UID
    fi
    #Check if the group with the same ID already exists
    GROUP=$(getent group $GID | cut -d: -f1)
    if [ ! -z "$GROUP" ]; then
      GROUP_OPT="-G $GROUP"
    elif [ ! -z "$GID" ]; then
      # Group don't exist but GID supplied
      addgroup -g $GID $NAME
      GROUP_OPT="-G $NAME"
    fi
  fi

  echo -e "$PASS\n$PASS" | adduser -h $FOLDER -s /sbin/nologin $UID_OPT $GROUP_OPT $NAME
  echo -e "$PASS\n$PASS" | smbpasswd -a $NAME
  mkdir -p $FOLDER
  chown $NAME:$GROUP $FOLDER
  unset NAME PASS FOLDER UID GID
done

cp /root/smb.conf /etc/samba/smb.conf

if [[ "${WORKGROUP}" ]]; then
    echo "   workgroup = ${WORKGROUP}" >> /etc/samba/smb.conf
fi

echo "" >> /etc/samba/smb.conf

exec $@
