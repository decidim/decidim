FROM gitpod/workspace-base:2023-03-21-19-31-17
USER root

# Install PostgreSQL
ENV PGVERSION=14
RUN apt-get install -y postgresql postgresql-client postgresql-server-dev-${PGVERSION} libpq-dev

# Setup the database user env vars, drop the default database cluster and change the folders to the workspace
# This makes it possible to persist the database within the workspace
ENV DATABASE_USERNAME=decidim
ENV DATABASE_PASSWORD=development
RUN pg_dropcluster $PGVERSION main \
  && rm -rf /etc/postgresql \
  && ln -s /workspace/etc/postgresql /etc/postgresql \
  && chown -h postgres:postgres /etc/postgresql

#### User space ####
USER gitpod

# Install nvm and Node
ENV NODE_VERSION=16.9.1
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | PROFILE=/dev/null bash \
    && bash -c ". .nvm/nvm.sh \
        && nvm install v${NODE_VERSION} \
        && nvm alias default v${NODE_VERSION} \
        && npm install -g npm yarn node-gyp" \
    && echo ". ~/.nvm/nvm.sh"  >> ~/.bashrc.d/50-node

# Install rbenv and Ruby
ENV RUBY_VERSION=3.1.1
RUN sudo apt-get install -y build-essential curl git zlib1g-dev libssl-dev \
  libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
  && echo 'eval "$(~/.rbenv/bin/rbenv init - sh)"' >> ~/.bashrc.d/60-ruby \
  && eval "$(~/.rbenv/bin/rbenv init - sh)" \
  && git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build \
  && git clone https://github.com/rbenv/rbenv-vars.git "$(rbenv root)"/plugins/rbenv-vars \
  && rbenv install $RUBY_VERSION && rbenv global $RUBY_VERSION
