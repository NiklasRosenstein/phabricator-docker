# Phabricator on Docker

  [Phabricator]: https://github.com/phacility/phabricator

Deploy Phabricator in a Docker LAMP stack. Start by creating a Docker Compose
configuration (see the `docker-compose.yml.template`) and then run

    $ docker-compose build
    $ docker-compose up -d
    $ docker-compose logs -f

If you run into an infinite  "Waiting for confirmation of MySQL service startup"
message loop, restart the container. tainer. This appears to be an issue with
the tutum/lamp image and will be gone after the first start.

    $ docker-compose restart
    $ docker-compose exec phab bin/storage upgrade --force
    $ docker-compose exec phab bin/phd start

### To do

* Alternate File Domain
* Sendmail Configuration
