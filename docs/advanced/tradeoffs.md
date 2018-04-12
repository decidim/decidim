# Technical tradeoffs

## Architecture

This is not your typical Ruby on Rails Vanilla App. We've tried using [Consul](http://decide.es) but we found some problems on reutilization, adaptation, modularization and configuration. You can read more about that on "[Propuesta de Cambios de Arquitectura de Consul](https://www.gitbook.com/book/alabs/propuesta-de-cambios-en-la-arquitectura-de-consul/details)".

## Turbolinks

Decidim doesn't support `turbolinks` so it isn't included on our generated apps and it's removed for existing Rails applications which install the Decidim engine.

The main reason is we are injecting some scripts into the body for some individual pages and Turbolinks loads the scripts in parallel. For some libraries like [leaflet](http://leafletjs.com/) it's very inconvenient because its plugins extend an existing global object.

The support of Turbolinks was dropped in [d8c7d9f](https://github.com/decidim/decidim/commit/d8c7d9f63e4d75307e8f7a0360bef977fab209b6). If you're interested in bringing turbolinks back, further discussion is welcome.

