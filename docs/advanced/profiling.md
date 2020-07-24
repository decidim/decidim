# How to profile a Decidim app

The developmen_app includes a bunch of gems that profile the application. Run the following command in the decidim root's folder:

```bash
bundle exec rake development_app
```

and then move into it and boot the server

```bash
cd developmen_app
bundle exec rails s
```

## Bullet

Bullet detects N+1 queries and suggests how to fix them, although it doesn't catch them all. It's currently configured in `config/initializers/bullet.rb` to log in the regular rails log and also in its own `log/bullet.log`. You'll now see entries like the following:

```bash
user: xxx
GET /
USE eager loading detected
  Decidim::Comments::Comment => [:author]
  Add to your query: .includes([:author])
Call stack
```

It also warns you when there's an unnecessary eager load.

More details: https://github.com/flyerhzm/bullet

## Rack-mini-profiler

This gem can analyze memory, database, and call stack with flamegraphs. It will show up in development on the top left corner and it gives you all sorts of profiling insights about that page. It'll tell you where the response time was spend on in the call stack.

This gem is further enhanced with the `flamegraph`, `stackprof` and `memory_profiler` gems which provide more detailed analysis. Try out by appending `?pp=flamegraph`, `?pp=profile-gc` or `?pp=analyze-memory` to the URL. You can read more about these options at https://github.com/MiniProfiler/rack-mini-profiler#flamegraphs.

More details: https://github.com/MiniProfiler/rack-mini-profiler

## Profiling best practices

You need to take the insights of these gems with a grain of salt though, if you run this in development. Rails' development settings have nothing to do with a production set up where classes are not reloaded and assets are precompiled and served from a web server. Therefore, you should mimic these settings as much as possible if you want your findings to be realistic.
