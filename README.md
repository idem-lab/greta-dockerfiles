# greta-dockerfiles

This repo hosts a dockerfile that installs the most up to date version of greta, that works for tensorflow 2 (`greta-dev/greta\@tf2-poke-tf-fun`). It also can download additional R packages if specified. 

To use:

1.  Download the Dockerfile or copy the contents of the file into a file named `Dockerfile` housed in your main project repo folder.

2.  Modify R version (if desired) in line 2.

3.  Add your name and email to lines 3 and 4.

4.  If you would like to include other R packages in the container, add them to the `Depends:` section of your `DESCRIPTION` file (see example in this repo). I recommend using `holepunch::write_compendium_description()` to do this because it automatically finds all packages used in your code (🪄).

5.  Modify date from which to install versions of R packages used in your analysis (if desired) in line 48 (this should match the R version selected in step 2.)

6.  Build dockerfile. I recommend naming your image with your dockerhub username and project name so that pushing to dockerhub later will be seamless: `docker build -t YOUR_DOCKERHUB_USERNAME/PROJECT_NAME .`

======

If you want to run your docker container, use `docker run -p 8787:8787 -e DISABLE_AUTH=true YOUR_DOCKERHUB_USERNAME/PROJECT_NAME`, then navigate in your web browser to *localhost:8787*.

After you're happy with the build, you may choose to push the image to dockerhub: `docker push YOUR_DOCKERHUB_USERNAME/PROJECT_NAME`
