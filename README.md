## Docker Container for Cantaloupe IIIF server

Rudimentary containerization of the [Cantaloupe server](https://medusa-project.github.io/cantaloupe), which bakes in a local filesystem 'resolver' (the means by which requested images are found) to a Docker data volume.

### Create the image

    docker build -t cantaloupe .

This invocation will download the 4.0.1 (current at time of writing) release of the software. To override for
newer (or older) versions:

    docker build --build-arg CANTALOUPE_VERSION=<desired version> -t cantaloupe .

### Run the container

 First you will need to set the environment variables required to run Cantaloupe. If you would like to test additional settings, ensure the cantaloupe.propoerties.tmpl template has the variable configured or you have set it as an environment variable.

    docker run -d -p 8182:8182 --name melon -v testimages/:/imageroot cantaloupe

will run the container in the background until _docker stop_ is called, looking in specified
directory for image files.

### Deployment to AWS

Currently we are deploying this container to AWS Fargate for testing purposes. The configuration and setup are being done using Terraform. The configuration files can be found in the [mitlib-terraform](https://github.com/MITLibraries/mitlib-terraform) GitHub Repository. JPEG2000 images are being stored and called from an S3 bucket for processing. These files are being uploaded manually to the S3 bucket for now.

### Todo/Explore

 Updating to ImageMagick 7. There is a commented out setup in the Dockerfile if we need to compile from source. Hopefully by the time ImageMagick 6 is no longer supported by Cantaloupe there will be an official Debian package we can use.
