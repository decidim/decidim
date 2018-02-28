FROM decidim/decidim:latest
LABEL maintainer="info@codegram.com"

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV RAILS_ENV production
ENV PORT 3000
ENV SECRET_KEY_BASE=no_need_for_such_secrecy
ENV RAILS_SERVE_STATIC_FILES=true

WORKDIR /code
COPY . .

# These two lines below will remove the `require` in `decidim-dev.gemspec`, which seems to be
# causing issues in certain circumstances using bundler. They should not be needed at all, so
# it's worth removing them in the future and checking out they work.
RUN sed -i '/require/d' decidim-dev/decidim-dev.gemspec
RUN sed -i "s/Decidim::Dev.version/\"$(cat .decidim-version)\"/g" decidim-dev/decidim-dev.gemspec

WORKDIR /code/decidim_app-design

RUN bundle install
RUN bundle exec rails assets:precompile
ENTRYPOINT []
CMD bundle exec rails s -p $PORT
