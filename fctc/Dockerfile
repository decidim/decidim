FROM ubuntu:24.04

# Ensure shell is bash
SHELL ["/bin/bash", "-l", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libyaml-dev \
    libncurses5-dev \
    libffi-dev \
    libgdbm-dev \
    libicu-dev \
    libpq-dev \
    postgresql-client \
    imagemagick \
    libvips \
    libvips-tools \
    && rm -rf /var/lib/apt/lists/*

# Create the non-root user
RUN useradd --create-home --shell /bin/bash app
USER app
WORKDIR /home/app
ENV HOME=/home/app

# Set up rbenv and ruby-build variables
ENV RBENV_ROOT=/home/app/.rbenv
ENV PATH="$RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH"

# Clone rbenv and its ruby-build/rbenv-vars plugins
RUN git clone https://github.com/rbenv/rbenv.git $RBENV_ROOT && \
    git clone https://github.com/rbenv/ruby-build.git $RBENV_ROOT/plugins/ruby-build && \
    git clone https://github.com/rbenv/rbenv-vars.git $RBENV_ROOT/plugins/rbenv-vars

# Initialize rbenv for bash sessions
RUN echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc

# Install Ruby, set it as global
ENV RUBY_VERSION=3.4.7
RUN rbenv install $RUBY_VERSION && \
    rbenv global $RUBY_VERSION

# Verify the system installation
RUN ruby -v && gem -v

# Install NodeJS via nvm
ENV NODE_VERSION=22.14.0
ENV NVM_DIR=/home/app/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
RUN source "$NVM_DIR/nvm.sh" && \
    nvm install "$NODE_VERSION" && \
    nvm alias default "$NODE_VERSION" && \
    nvm use default && \
    npm install -g yarn

# Add Node and Yarn paths to the permanent environment
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"

# Install Decidim and generate the application
RUN gem install decidim --version '= 0.32.0'
RUN decidim FCCLT_Decidim

WORKDIR /home/app/FCCLT_Decidim

# rbenv-vars picks this up automatically for any rbenv-shimmed ruby/rails command
RUN printf 'DATABASE_HOST=postgres\nDATABASE_USERNAME=postgres\nDATABASE_PASSWORD=postgres\n' > .rbenv-vars

COPY --chown=app:app entrypoint.sh /home/app/entrypoint.sh
RUN chmod +x /home/app/entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/home/app/entrypoint.sh"]
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
