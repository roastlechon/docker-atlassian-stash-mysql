# Docker: Atlassian Stash (with MySQL Connector)

This project is my own rendition of a Dockerfied Atlassian Stash. You can link this with a [MySQL Docker image](https://github.com/roastlechon/docker-mysql).

```bash
# cd into the git repository
cd /path/to/repo/docker-atlassian-stash-mysql
# Build a Docker image named "atlassian-stash" from this location "."
sudo docker build -t atlassian-stash .

# Run the docker container
sudo docker run --name atlassian-stash -p 7999:7999 -v /data/stash:/var/atlassian/application-data/stash -d atlassian-stash /sbin/my_init
```

* `docker run` - Creates and runs a new Docker container based off an image.
* `--name atlassian-stash` - Names the newly run container.
* `-p 7999:7999` - Binds a port of the container to a port on the host
* `-v /data/stash:/var/atlassian/application-data/stash' - Mounts a host directory as a data volume. Can be interchanged with using a Data Volume Container.
* `-d atlassian-stash` - Uses the image "atlassian-stash" to create the Docker container.
* `/sbin/my_init` - Run the init scripts used to kick off long-running processes and other bootstrapping, as per [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker)

## Data Volume Container

For best portability, it is advised to use a data volume container to persist and share data between containers. See [Creating and mounting a Data Volume Container](https://docs.docker.com/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container) on the Docker documentation.

The quickest way to launch a Data Volume Container is to run a command.

```bash
sudo docker run -d -v /var/atlassian/application-data/stash --name stash_data busybox true
# Verify that it was created and exited. (Data Volume Containers don't need to be running to use them)
sudo docker ps -a
# You should see a list of containers. Look for busybox image with a name "stash_data"
CONTAINER ID        IMAGE                    COMMAND                CREATED             STATUS                      PORTS                         NAMES
92a411232665        busybox:latest           true                   20 seconds ago      Exited (0) 19 seconds ago                                 stash_data
```

When you have your Data Volume Container created, you can use it with your container:

```bash
sudo docker run --name atlassian-stash --volumes-from stash_data -d atlassian-stash /sbin/my_init
```

## Linking with MySQL

For even more separation of concerns, you can link a MySQL container to the Stash container.

```bash
# Assume that mysql image is run
sudo docker run --name mysql --volumes-from mysql_data -e MYSQL_USER=username -e MYSQL_PASS=password123 -d mysql /sbin/my_init

# Run this command to link mysql
sudo docker run --name atlassian-stash -p 7999:7999 --link mysql:stash_mysql --volumes-from stash_data -d atlassian-stash /sbin/my_init
```

* `--link mysql:stash_mysql` - Links a container named mysql. The second part `stash_mysql` is an alias that the container can use to communicate with the mysql container. If you look at the hosts file of atlassian-stash container, you can see that stash_mysql routes to the mysql IP address.