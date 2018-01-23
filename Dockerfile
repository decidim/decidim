FROM decidim/decidim:latest-dev

RUN apt-get update -qq && \
    apt-get install -y sudo && \
    apt-get clean

RUN adduser --home /code --shell /bin/bash --disabled-password --gecos "" decidim && \
    adduser decidim sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN echo 'Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/gems/bin"' > /etc/sudoers.d/secure_path
RUN chmod 0440 /etc/sudoers.d/secure_path
