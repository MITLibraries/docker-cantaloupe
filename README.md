## Docker Container for Cantaloupe IIIF server ##

Rudimentary containerization of the [Cantaloupe server](https://medusa-project.github.io/cantaloupe), which bakes in a local filesystem 'resolver' (the means by which requested images are found) to a Docker data volume.

This branch uses an HttpResolver and accepts a URLsafe Base64 encoded URI as
the identifier and returns the requested image (caching it to disk).

### Use a pre-built image

This is recommended unless you are making changes to the image, at which point
you will need to build and run the container as noted below.

    docker run -d -p 8182:8182 mitlibraries/cantaloupe:tryiiif


### Create the image if you don't want to use Docker Hub ###

    docker build -t cantaloupe .

This invocation will download the 2.2 (current at time of writing) release of the software. To override for
newer (or older) versions:

    docker build --build_arg ctl_ver=<desired version> -t cantaloupe .

### Run the container ###

    docker run -d -p 8182:8182 --name melon cantaloupe

will run the container in the background until _docker stop_ is called.
