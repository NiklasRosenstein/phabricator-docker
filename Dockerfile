FROM tutum/lamp:latest
RUN apt-get update && apt-get install -y php5-curl php5-mysqlnd php5-gd python3-pygments
RUN rm -rf /app
RUN rm /etc/apache2/sites-enabled/000-default.conf

# Install the Phabricator sources.
RUN mkdir -p /app
WORKDIR /app
RUN git clone https://github.com/phacility/libphutil.git
RUN git clone https://github.com/phacility/arcanist.git
RUN git clone https://github.com/phacility/phabricator.git

WORKDIR /app/phabricator

# Install our Phabricator configuration.
COPY support-files/phabricator.conf /etc/apache2/sites-enabled/phabricator.conf
COPY support-files/preamble.php support/preamble.php
RUN php -l support/preamble.php

# Configure Phabricator.
ARG BASE_URI
ARG REPO_PATH
ARG TIMEZONE
RUN bin/config set phabricator.base-uri $BASE_URI
RUN bin/config set phabricator.timezone $TIMEZONE
RUN bin/config set repository.default-local-path $REPO_PATH

# Configure PHP
RUN echo 'always_populate_raw_post_data=-1' >> /etc/php5/apache2/php.ini

# Configure MySQL
COPY support-files/mysql.conf /etc/mysql/conf.d/phabricator-mysql.conf
RUN cat /etc/mysql/conf.d/phabricator-mysql.conf

# Create a pygmentize binary (does not come with the package).
COPY support-files/pygmentize /bin/pygmentize
RUN chmod +x /bin/pygmentize

CMD /run.sh
