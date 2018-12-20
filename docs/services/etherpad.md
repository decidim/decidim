# Etherpad

Decidim can be integrated with Etherpad so meetings can have their own pads.

In order to use it you need to have your own Etherpad deployment, you can do it
with the Docker compose using the provided `docker-compose-etherpad.yml`.

You should edit that file to configure the environment variables and then run:

```sh
docker swarm init # just one time

docker stack deploy --compose-file docker-compose-etherpad.yml decidim-etherpad
```

After deploying it, you should set the Etherpad host and API Key at
`config/initializers/decidim.rb` and `config/secrets.yml`
