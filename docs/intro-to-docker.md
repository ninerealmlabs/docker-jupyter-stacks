# Intro to docker

- [Intro to docker](#intro-to-docker)
  - [Installation](#installation)
    - [Notes on Apple Silicon](#notes-on-apple-silicon)
    - [\[Optional?\] Create dockerhub account](#optional-create-dockerhub-account)
  - [Getting started with Docker CLI](#getting-started-with-docker-cli)
  - [Tips \& Tricks](#tips--tricks)
  - [Intro to docker/jupyter stacks](#intro-to-dockerjupyter-stacks)
  - [Docker Volumes](#docker-volumes)
  - [Docker-Compose](#docker-compose)
    - [Create docker-compose.yaml](#create-docker-composeyaml)
    - [Creating containers with docker-compose](#creating-containers-with-docker-compose)
  - [Pull from Azure Container Registry](#pull-from-azure-container-registry)

## Installation

Windows/Mac: Install [docker desktop](https://www.docker.com/products/docker-desktop)
Linux: [Install .deb or .rpm package](https://docs.docker.com/engine/install/)

> You may want to disable "start Docker on boot" since it (can) reserve system resources for use with containers

### [Notes on Apple Silicon](https://docs.docker.com/docker-for-mac/apple-silicon/)

Multi-platform builds are not common; you may have to emulate AMD64 architecture

1. You must install Rosetta 2 as some binaries are still Darwin/AMD64.
  To install Rosetta 2 manually from the command line, run the following command:

   ```sh
   softwareupdate --install-rosetta
   ```

2. Emulate AMD64 during container launch with `--platform linux/amd64`

### [Optional?] Create dockerhub account

- An account on DockerHub may be required to pull images, and is required to push images to a DockerHub repository.
- If account creation is required, create a Personal Access Token (and save it) for command-line use
- If you get an authentication error during any of the steps below, run `docker login` and provide PAT

> Recall: _DockerHub:GitHub::Azure Container Registry:Azure Repos_

## Getting started with Docker CLI

1. Make sure Docker is running (i.e., start Docker Desktop)
2. [Docker's Getting Started guide](https://docs.docker.com/get-started/)
3. Get help

   ```sh
   docker help
   ```

4. Create your first container

   ```sh
   docker run -d -p 80:80 docker/getting-started
   ```

   - `run` creates a _container_ from an _image_
   - `-d` runs in _detached_ mode (i.e., does not )
   - `-p 80:80` specifies _host:container_ port mapping
   - `docker/getting-started` specifies _REPOSITORY / CONTAINER_

5. Let's dig into those options. What happens if...?

   - Rerun command

   ```sh
   docker run -d -p 80:80 /docker/getting-started
   # Error: host port is already used;
   ```

   _try with `-p 81:80`_

   - Run without `-d` flag

   ```sh
   docker run -p 88:80 docker/getting-started
   ```

   _Since we're not in detached mode, we see container running in terminal (hit `ctrl-c` to exit)_

6. After all that, let's see what `images` and `containers` we have on our system

   - Check local images

     ```sh
     docker image ls
     ```

   - Check local containers

     ```sh
     docker container ls
     docker container ls -a
     # why are these different?
     ```

   - The `ls` command works with other docker components, like `network`, `secret`, and `volume` --
     but those are beyond the scope of this intro

7. Stop & Delete containers with `docker stop` and `docker rm`

   - Let's remove our first container

     ```sh
     docker rm docker/getting-started
     # No such container --
     # What does `docker container ls -a` say?
     # Note CONTAINER ID and NAMES
     ```

   - Let's delete with ID this time

     ```sh
     docker rm <FIRST FEW CHARACTERS OF ID>`
     # or
     docker rm <NAME>
     ```

8. Review existing images and containers: (hint: `docker image ls` vs `docker container ls`)
9. Don't want to do lots of typing? You can clear all stopped containers at once:

   ```sh
   docker container prune
   ```

## Tips & Tricks

1. Specify container name with `--name <NAME>` -- specified name must be unique _across all containers_:

   ```sh
   docker run -d -p 80:80 --name start docker/getting-started
   docker run -d -p 8080:80 --name start docker/getting-started
   # docker: Error response from daemon: Conflict. The container name "/start" is already in use by container
   ```

2. View logs from running containers

   ```sh
   docker logs <ID OR NAME>
   ```

3. Gain access to "inside" of running container

   ```sh
   docker exec -it OR NAME < ID > /bin/bash
   ```

## Intro to [docker/jupyter stacks](https://hub.docker.com/u/jupyter/)

1. Get the image

   ```sh
   docker pull jupyter/minimal-notebook
   # using default tag: latest
   ```

   - Tags are ways to time- / version- / build- stamp images so you can always `pull` the same image
     (or find a compatible one if it exists)
   - See other tags [here](https://hub.docker.com/r/jupyter/minimal-notebook/tags?page=1&ordering=last_updated)
   - Tag "latest" is convenient, but should not be used in production in case of breaking changes
     (instead, pin to a specific image:tag)

2. Check image list

   ```sh
   docker image ls
   ```

3. Inspect new image - quick look at metadata

   ```sh
   docker inspect jupyter/minimal-notebook:latest
   ```

4. Run a jupyter container

   ```sh
   docker run -d -p 8888:8888 --name jupyter jupyter/minimal-notebook
   ```

   - Ok, now what? How do we get to the notebook?
   - We're running in `detached` mode (see the `-d` flag?), so we have to look at the container logs:

     ```sh
     docker logs jupyter
     ```

   - Alternatively, we could run in standard mode (without the `-d`),
     but then we have to keep the terminal session open:

     ```sh
     # stop current `jupyter` container
     docker kill jupyter # alternative to "docker container stop"
     docker container rm jupyter
     docker run -p 8888:8888 --name jupyter jupyter/minimal-notebook
     # `ctrl-c` to exit -- this will stop the container!
     ```

> ### Exercise
>
> 1. Stop and remove all running containers
> 2. Create a clean slate with `docker container prune` and allow. This removes all stopped containers
> 3. Start a new `jupyter/minimal-notebook` instance
> 4. Create a new .ipynb and save it
> 5. Shut down the container
> 6. Run `docker container ls -a` to get the container name and restart the container (hint: `docker start...`)

## Docker [Volumes](https://docs.docker.com/storage/volumes/)

1. Where is our data?

   - Remember that a _container_'s universe initially only comprises what was included in the docker _image_
   - If we make changes to a container, that change is **ephemeral** -- it only applies to the specific container
     for the duration of its existence.
   - _Translation_: if we delete the `jupyter/minimal-notebook` container where we created our .ipynb,
     that .ipynb ceases to exist.

   This is where Docker Volumes come in - they allow persisting data outside of a container's ephemeral lifecycle:

   > Volumes are often a better choice than persisting data in a container's writable layer,
   > because a volume does not increase the size of the containers using it,
   > and the volume's contents exist outside the lifecycle of a given container.

2. Do we have any volumes currently?

   ```sh
   docker volume ls
   ```

3. We can mount our local folders into the image:

   ```sh
   docker run -p 8888:8888 -v /path/to/mount/dir:/home/jovyan/work --name jupyter jupyter/minimal-notebook
   ```

   - `-v` mounts a named docker volume or bind mounts a directory using `host/path:container/path` mapping
     > Docker will work with forward slashes ("/") on Windows Command Line (CMD) or Windows PowerShell (PS)
   - `/home/jovyan/work` is the default mount location for `jupyter` images

> Note: There is a difference between a "docker volume" and a "bind mount".
> Both allow data to exist outside of the ephemeral nature of containers;
> however bind mounts pass a local directory tree into the container runtime allowing
> fileshare between host and container, whereas volumes simply store data created
> in a container on your local hard drive without easy transparency
>
> In our case with jupyter, we want a bind mount - we want to access our local files in the container.
>
> A use case for a volume would be a container hosting a database. We wouldn't necessarily care
> to access the database files from our local computer,
> but we _would_ want those files persisted outside of the container

---

## Docker-Compose

`Docker-compose` is a command-line interface for a file-based method of declaratively managing the container lifecycle.

The Compose file is a YAML file [defining services, networks and volumes](https://github.com/compose-spec/compose-spec/blob/master/spec.md).

### Create [docker-compose.yaml](https://docs.docker.com/compose/compose-file/compose-file-v3/)

> Tip: You can use either a `.yml` or `.yaml` extension for this file. They both work.

Recall our `docker run` command:

```sh
# docker run command
MOUNT_DIR="/Users/agraber/_GitProjects"
docker container run \
  --rm \
  -d \
  -p 8888:8888 \
  --mount type=bind,source=${MOUNT_DIR},target=/home/jovyan/work \
  --env JUPYTER_ENABLE_LAB=yes \
  --name jupyter \
  jupyter/scipy-notebook \
  start.sh jupyter lab
```

Let's create a compose file for our jupyter example:
_The below command is a cheat to create the `docker-compose.yaml` file in your current directory_

```sh
MOUNT_DIR="/Users/agraber/_GitProjects"
cat << EOF > ./docker-compose.yaml
version: '3.7'

services:
  jupyter:  # this is the *service* name
    ports:
      - "8888:8888"
    volumes:
      - type: bind
        source: ${MOUNT_DIR}
        target: /home/jovyan/work
    environment:
      - JUPYTER_ENABLE_LAB=yes
    container_name: jupyter  # this is the *container* name
    image: jupyter/scipy-notebook
    command: start.sh jupyter lab
EOF
```

### Creating containers with docker-compose

1. Make sure Docker is running (i.e., start Docker Desktop)
2. [Docker-compose CLI reference](https://docs.docker.com/compose/reference/)
3. Get help

   ```sh
   docker-compose help
   ```

4. To create a container with docker-compose, run `docker-compose up`

   - Open ./docker-compose.yaml

   - Just like `docker` commands in the CLI, `docker-compose` files can use variable substitution.
     Let's create a .env file to retain our environmental variables

     ```sh
     # Next time you can just edit the .env file!
     touch .env
     echo MOUNT_PATH="/Users/agraber/_GitProjects" >> .env
     echo IMG_NAME="jupyter/scipy-notebook" >> .env
     echo CONTAINER_NAME="jupyter" >> .env
     ```

   - Now start the container

     ```sh
     docker-compose up -d # detached, same as `docker run`
     docker-compose up -f /path/to/docker-compose.yaml
     ```

     - Why are some layers already present? `scipy-notebook` is build on top of `minimal-notebook`.
       Since we previously pulled `minimal-notebook`, docker is saving us some work and using the parts
       from `minimal-notebook` that it can when launching `scipy-notebook`

5. You can interact with running containers using the `docker` commands we learned before

   ```sh
   docker logs jupyter
   docker exec -it jupyter
   ```

   Or you can use `docker-compose` versions

   ```sh
   docker-compose logs jupyter
   docker-compose exec jupyter /bin/bash
   ```

6. To stop a container, run `docker-compose down`

   ```sh
   docker-compose down
   docker-compose down -f /path/to/docker-compose.yaml
   ```

## Pull from Azure Container Registry

Docker naturally assumes that you will be pulling from dockerhub,
however there are many other container registries ([quay.io](quay.io), [ghcr.io](ghcr.io), etc).

PMI has private container registries through its Azure subscription.

To pull from a non-docker registry, simply prepend the registry url to the front of the image --
Instead of `image:tag`, it becomes `registry/image:tag`

See [README.md](../README.md)

> To use our images, update the `IMG=` line in your `.env` to point to our `registry/image:tag`
