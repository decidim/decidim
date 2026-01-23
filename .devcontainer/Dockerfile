ARG RUBY_VERSION=3.4.7
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

RUN sudo apt-get update && \
  sudo apt-get install -y libicu-dev

ENV BINDING="0.0.0.0"
