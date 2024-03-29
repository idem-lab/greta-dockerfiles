# Use rocker/rstudio as the base image. this sets most recent built version.
FROM rocker/rstudio:4.3.0
LABEL maintainer="YOUR NAME"
LABEL email="YOUR EMAIL.COM"

# Install extra packages that are needed for the greta install
RUN apt-get update
RUN apt-get install -y libpng-dev pciutils

# Remove package lists to reduce image size
RUN rm -rf /var/lib/apt/lists/*

# Create a writable directory for pip cache and give rstudio user access
RUN mkdir -p /home/rstudio/.cache/pip && chown -R rstudio:rstudio /home/rstudio/.cache/pip

# ---------------------------------------------

ENV NB_USER rstudio
ENV NB_UID 1000

# And set ENV for R
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron
RUN echo "export PATH=${PATH}" >> ${HOME}/.profile

# The `rsession` binary that is called by nbrsessionproxy to start R does not seem to start
# without this being explicitly set
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib

ENV HOME /home/${NB_USER}
WORKDIR ${HOME}

# ---------------------------------------------

USER root

# Copy only the description file for the project
# COPY ./DESCRIPTION ${HOME}
# Copy your entire repo to the container
COPY . ${HOME}

RUN chown -R ${NB_USER} ${HOME}

# --------------------------------------------

# Install packages based on DESCRIPTION file in repository.
## Date for package version can be modified
## Inspired from Holepunch package, by Karthik Ram: https://github.com/karthik/holepunch
RUN if [ -f DESCRIPTION ]; then R --quiet -e "install.packages('remotes'); options(repos = list(CRAN = 'https://packagemanager.posit.co/cran/2023-06-16/')); remotes::install_deps()"; fi

# --------------------------------------------

# Install greta - if using previous/CRAN version can add greta to the description file and use above line only
RUN R --quiet -e "remotes::install_github('greta-dev/greta@tf2-poke-tf-fun', upgrade = TRUE)"

# Install dependencies for greta
RUN R -e "reticulate::install_miniconda(); reticulate::conda_create(envname = 'greta-env-tf2', python_version = '3.8')"

# Giver docker user "rstudio" access to the conda environment
RUN chown -R rstudio:rstudio /home/rstudio/.local/share/r-miniconda/envs/greta-env-tf2

# Write bash script containing shell code that is run with:
# `reticulate::py_install( packages = c( 'numpy', 'tensorflow', 'tensorflow-probability'), pip = TRUE)
RUN echo ". /home/rstudio/.local/share/r-miniconda/bin/activate" >> /home/rstudio/activate_env.sh \
    && echo "conda activate '/home/rstudio/.local/share/r-miniconda/envs/greta-env-tf2'" >> /home/rstudio/activate_env.sh \
    && echo "'/home/rstudio/.local/share/r-miniconda/envs/greta-env-tf2/bin/python' -m pip install --upgrade --no-user numpy tensorflow tensorflow-probability" >> /home/rstudio/activate_env.sh

# Make the script executable and execute it
RUN chmod +x /home/rstudio/activate_env.sh \
    && /home/rstudio/activate_env.sh

# Restart R
CMD ["R"]

# --------------------------------------------

# Expose RStudio port
EXPOSE 8787

# Start RStudio Server on container startup
CMD ["/init"]
