ARG RUBY_VERSION=3.4.7
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

RUN wget -q -O /tmp/google-chrome-key.pub https://dl-ssl.google.com/linux/linux_signing_key.pub \
    && sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg /tmp/google-chrome-key.pub \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list \
    && sudo apt-get update \
    && sudo apt-get install -y google-chrome-stable libicu-dev \
    && sudo rm -rf /var/lib/apt/lists/* /tmp/google-chrome-key.pub

ENV BINDING="0.0.0.0"
