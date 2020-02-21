# MIT Libraries Cantaloupe Docker Container

This is our [Cantaloupe](https://cantaloupe-project.github.io/) container used in production. While you are welcome to use this container, and we appreciate PRs, the primary purpose of this repo is managing our production image.

The `cantaloupe.properties.sample` file is the distributed version without modifications. All setting changes are handled through environment variables.

## Local Development

There is a docker-compose file that will spin up an instance of minio as well as the IIIF server. The cantaloupe instance is configured to mostly track the production configuration which uses S3 for both the source and derivative cache. To start just run: `docker-compose up`.

The minio server can be accessed at http://localhost:9000. The default username and password are `minio` and `password`. If you want to change these you can set the `MINIO_USERNAME` and `MINIO_PASSWORD` environment variables in a `.env` file. You will need to create a bucket called `images` and upload an image file to it. You should then be able to access the image through cantaloupe. For example, if you upload a file called `test.jp2` then you can see a JPEG version of the image scaled to 300 width at http://localhost:8182/iiif/2/test.jp2/full/300,/0/default.jpg.

If you make changes to the Dockerfile, you will need to run `docker-compose build`.

## Deployment to AWS

To publish a new staging build run `make publish`. To promote the current staging build to production run `make promote`.

## ToDo/Explore

 Updating to ImageMagick 7. There is a commented out setup in the Dockerfile if we need to compile from source. Hopefully by the time ImageMagick 6 is no longer supported by Cantaloupe there will be an official Debian package we can use.

[Source chunking](https://medusa-project.github.io/cantaloupe/manual/4.1/sources.html). This is a new feature in Cantaloupe 4.1 and is supported by the KakaduNativeProcessor. 
