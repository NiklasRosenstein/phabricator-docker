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
ARG PHAB_BASE_URI
ARG PHAB_REPO_PATH
ARG PHAB_TIMEZONE
RUN bin/config set phabricator.base-uri $PHAB_BASE_URI
RUN bin/config set phabricator.timezone $PHAB_TIMEZONE
RUN bin/config set repository.default-local-path $PHAB_REPO_PATH
RUN bin/config set pygments.enabled true

# Configure PHP
ARG PHP_POST_MAX_SIZE
RUN echo 'always_populate_raw_post_data=-1' >> /etc/php5/apache2/php.ini
RUN echo 'post_max_size=$PHP_POST_MAX_SIZE' >> /etc/php5/apache2/php.ini

# Configure MySQL
COPY support-files/mysql.cnf /etc/mysql/conf.d/phabricator-mysql.cnf

# Create a pygmentize binary (does not come with the package).
COPY support-files/pygmentize /bin/pygmentize
RUN chmod +x /bin/pygmentize

CMD /run.sh
