# How to test Decidim engines

## Requirements

You need to create a dummy application to run your tests. Run the following command in the decidim root's folder:

```bash
bundle exec rake test_app
```

## Running the test suite

A Decidim engine can be tested running the following command inside its folder:

```bash
bundle exec rake
```

# Test using docker

You can test the engines using docker-compose, just run this replacing `decidim-[engine]` with the proper decidim engine to test, ex: `decidim-verifications`:

```bash
docker-compose run --rm decidim bundle
docker-compose run --rm decidim bundle exec rake test_app
docker-compose run --rm decidim bash -c "cd decidim-[engine] && bundle exec rake"
```

Please be sure to pull the latest image of decidim

```bash
docker-compose pull
```
