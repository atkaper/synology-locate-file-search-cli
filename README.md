# locate / mlocate / updatedb - Synology File Search in a docker container

Synology "forgot" to add the linux "locate" command in their NAS systems.
As I quite like the speed of it, I added a locate implementation, by just running it inside a docker container, on the NAS itself.

This setup has a batch runner/cron-like script, which executes a re-index every night.
Persistence of the index is done outside of the container, and all folders to be indexed are mapped to the docker image for indexing (read only).

File descriptions:

```
build.sh               - use this to build the docker image (runs outside of container).
Dockerfile             - this describes what will be put in the image.
indexer.sh             - this is the batch/cron like runner, it runs updatedb.sh every night (runs inside container).
updatedb.sh            - this is the script which does the indexing (runs inside container).
run.sh                 - use this to start the container (runs outside of container).
stop.sh                - use this to stop the container - index will be kept (runs outside of container).
locate-alias.sh        - this contains the alias commands for search and re-index triggering (runs outside of container).
```

The updatedb.sh assumes that all folders to be indexed live in /volume1 on your NAS. If not, the script must be updated!
In that case, just search for volume1 and replace by the proper name. You can at this time NOT index multiple
volumes, like /volume1/someshare and /volume2/anothershare, but you can index multiple folders inside one volume.
For example: /volume1/download, /volume1/music, /volume1/docker. If you need multiple volumes, the simplest
solution is to index / instead of /volume1 in the scripts. This will also index the docker system files, but
you could ignore them when searching, or maybe add an exclude option to skip them in the updatedb.mlocate command.

To install this search setup, copy all the files to your nas, for example in folder /volume1/docker/mlocate/
In there, execute the following command (if you need to change /volume1 name, do it before this build):

```
./build.sh
```

This above line builds the docker container. It uses an ubuntu base image, adds mlocate, and copies the scripts in there.

Edit the run.sh script, to have all folders you want to index. They must be mapped to /volume1/ in the container.
I have three indexed folders for now:

- /volume1/download/
- /volume1/music/
- /volume1/docker/

Which can be seen in run.sh as:

```
   -v /volume1/download/:/volume1/download/:ro \
   -v /volume1/music/:/volume1/music/:ro \
   -v /volume1/docker/:/volume1/docker/:ro \
```

Make sure to add folders you want indexed in the same way. Each on a separate line, ending in a backslash.
And make sure you do NOT remove the (not shown) -v line, which maps to /var/lib/mlocate, as that will contain the index.

Note: better do NOT map you synology root "/" to some docker folder, and also do not map complete "/volume1"
from synology to docker /volume1. This will work, but will NOT mount the volume readonly, which might be a
security risk. Better mount all to be indexed folders separately. See later in this REAME.md on how to do that.

When run.sh is OK, then execute the next commands:

```
# start container, which runs nightly index:
./run.sh

# load aliases for "locate" and "updatedb":
. ./locate-alias.sh

# re-index NOW
updatedb

# try finding some file (note: the container MUST be running for this to work!)
locate [PARTIAL_FILENAME_OF_FILE_YOU_KNOW_EXISTS]
```

And that's the initial installation. Note: the container does not use many resources. While sleeping less than 250K memory, and no CPU.
Only at night, resource use will shortly increase a bit, when indexing.

To make the "locate" and "updatedb" aliases available after every logon, you should add this line to your ~/.profile:

```
# next line must start with a dot and a space. This will add the aliases to the current shell context. Wont work without dot-space!
. /volume1/docker/mlocate/locate-alias.sh
```

Where /volume1/docker/mlocate/ of course must reflect the location where you installed the scripts.

Note: out of the box, only root can execute docker commands. If you do not want to run as root, to type "locate", there are multiple options to fix this.

```
# option 1 - enable docker commands for all users in the admininstrators group:
sudo chown root:administrators /var/run/docker.sock

# option 2 - add "sudo " in front of the docker commands in the locate-alias.sh file, like this:
alias locate="sudo docker exec -ti mlocate locate"
alias updatedb="sudo docker exec -ti mlocate /updatedb.sh"
```

Both of these assume that your user is an admin user.
Being able to run docker commands effectively gives the user root/admin access over the NAS.
Note: a NAS OS update might remove the above "workarounds". In that case, you need to re-do one of them.

If you need a safer construction (for non-admin users), then you could make two scripts in /usr/local/bin, and add a line to /etc/sudoers to allow root for these.
In that case, do NOT load the aliases, as those will interfere with this setup.

File /usr/local/bin/locate:

```
#!/bin/bash

docker exec -ti mlocate locate "$@"
```

File /usr/local/bin/updatedb:

```
#!/bin/bash

docker exec -ti mlocate /updatedb.sh
```

Add a line at the bottom of /etc/sudoers:

```
%users ALL=(ALL) NOPASSWD: /usr/local/bin/locate,/usr/local/bin/updatedb
```

And then any user can type "sudo locate test123", or "sudo updatedb".

Note: I have not tested this last setup yet, but should work fine.


Thijs Kaper, May 8, 2021.

