## Docker Container for Cantaloupe IIIF server
[![Build Status](https://travis-ci.com/UCLALibrary/docker-cantaloupe.svg?branch=master)](https://travis-ci.com/UCLALibrary/docker-cantaloupe) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/0339f09b793a4f3ea37e09f5e1c3b66b)](https://www.codacy.com/app/UCLALibrary/docker-cantaloupe?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=UCLALibrary/docker-cantaloupe&amp;utm_campaign=Badge_Grade)

Rudimentary containerization of the [Cantaloupe server](https://cantaloupe-project.github.io/cantaloupe), which bakes in a local filesystem 'resolver' (the means by which requested images are found) to a Docker data volume.

### Create the image

    docker build -t cantaloupe .

This invocation will download the 4.1.2 (current at time of writing) release of the software. To override for
newer (or older) versions:

    docker build --build-arg CANTALOUPE_VERSION=<desired version> -t cantaloupe .

_Note:_ if you want to build a version other than 4.1.2, 4.1, 4.0.3, or 4.0.2 you will need to supply a Cantaloupe properties `template` and `defaults` file in the `configs` directory. These files should be named with the Cantaloupe version you are interested in building. If the version you need is close to one of the supplied version files, you can probably just copy that file and edit as appropriate.

To build the latest development snapshot of Cantaloupe, use the following:

    docker build --build-arg CANTALOUPE_VERSION="dev" -t cantaloupe .

If the upstream Cantaloupe project is broken, you can also build a last known good commit (or a previous tag or working branch). To do this, supply a `COMMIT_REF` argument with a commit hash, tag, or branch name:

    docker build --build-arg CANTALOUPE_VERSION="dev" --build-arg COMMIT_REF="437a72d7" -t cantaloupe .

### Run the container

 First you will need to set the environment variables required to run Cantaloupe. If you would like to test additional settings, ensure the cantaloupe.properties.tmpl template has the variable configured or you have set it as an environment variable.

    docker run -d -p 8182:8182 --name melon -v /path/to/your/images:/imageroot cantaloupe

will run the container in the background until _docker stop_ is called, looking in specified directory for image files.

 You can also run the container with environmental variables supplied on the command line like:

    docker run -d -p 8182:8182 \
      -e "CANTALOUPE_ENDPOINT_ADMIN_SECRET=[my_secret_password]" \
      -e "CANTALOUPE_ENDPOINT_ADMIN_ENABLED=true" \
      --name melon -v testimages:/imageroot cantaloupe

### Run the container using docker-compose

The current docker-compose.yml defines fixed environment variables in .docker-compose.env. As of now, the environment file just contains configurations for the administrative endpoint. This compose file currently does not build a local image. It only grabs the latest tag on of uclalibrary/cantaloupe. Please change the SHARED_IMAGE_DIR env variable to your associated image path to be shared with the local cantaloupe container. Run the following to start the container with compose:

    export SHARED_IMAGE_DIR=/tmp/imageshare; docker-compose up -d

### Deployment to AWS

Currently we are deploying this container to AWS Fargate for testing purposes. The configuration and setup are being done using Terraform. The configuration files can be found in the [mitlib-terraform](https://github.com/MITLibraries/mitlib-terraform) GitHub Repository. JPEG2000 images are being stored and called from an S3 bucket for processing. These files are being uploaded manually to the S3 bucket for now.

### How to run the tests

We are using [DockerSpec](https://github.com/zuazo/dockerspec) to test our Dockerfiles. This requires that you have Ruby and Bundler installed. Once you do, you can run the following to install the testing dependencies:

    bundle

And, after that, you can type the following to run the tests:

    rake

If you want to run just the tests for the "dev" or "stable" builds, you can run either `rake test_dev` or `rake test_stable`.

### Optional stuff

It is possible, if you have a kakadu license, to have the build also build and configure kakadu for use with your Cantaloupe server. To do this, you will need to place the source code directory that Kakadu Software has given you (it has your license as its name) into this project's `kakadu` directory. When you do this, and supply and additional build-arg to the build, you will cause kakadu to be installed and configured on your image. If you'd like a peak at the CodeBuild configuration we use to build kakadu, look at the `.buildspec.yml` file. Since kakadu is proprietary software and we can't make the source code available publicly, this build takes place in private on our AWS infrastructure.

The additional build-arg that needs to be supplied to the build is `KAKADU_VERSION`. Its value would be your kakadu license code, which also has the release version of kakadu included in its name. This will look something like:

    docker build --build-arg KAKADU_VERSION=v7_A_7-21061X -t cantaloupe .

If you encounter any problems with the build using your kakadu source code, we would be interested in hearing about them.

### TODO

 Updating to ImageMagick 7. There is a commented out setup in the Dockerfile if we need to compile from source. Hopefully by the time ImageMagick 6 is no longer supported by Cantaloupe there will be an official Debian package we can use.
