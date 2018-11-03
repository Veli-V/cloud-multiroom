FROM debian:stretch-slim

RUN set -ex \
    # Official Mopidy install for Debian/Ubuntu along with some extensions
    # (see https://docs.mopidy.com/en/latest/installation/debian/ )
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        dumb-init \
        gcc \
        gnupg \
        gstreamer1.0-alsa \
        gstreamer1.0-plugins-bad \
        python-crypto \
        wget \
 && curl -L https://apt.mopidy.com/mopidy.gpg | apt-key add - \
 && curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        mopidy \
        mopidy-soundcloud \
        mopidy-spotify \
 && curl -L https://bootstrap.pypa.io/get-pip.py | python - \
 && pip install -U six \
 && pip install \
        Mopidy-Moped \
        Mopidy-GMusic \
        Mopidy-Pandora \
        cryptography \
        pyasn1 \
        pyopenssl \
        requests[security] \
        youtube-dl \
 && mkdir -p /var/lib/mopidy/.config/mopidy \
 && ln -s /config/ /var/lib/mopidy/.config/mopidy \
    # Clean-up
 && apt-get purge --auto-remove -y \
        curl \
        gcc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

# Start helper script.
COPY entrypoint.sh /entrypoint.sh

# Default configuration.
COPY mopidy.conf /config/mopidy.conf

# Copy the pulse-client configuratrion.
COPY pulse-client.conf /etc/pulse/client.conf

# Allows any user to run mopidy, but runs by default as a randomly generated UID/GID.
ENV HOME=/var/lib/mopidy
RUN set -ex \
 && usermod -u 84044 mopidy \
 && groupmod -g 84044 audio \
 && chown mopidy:audio -R $HOME /entrypoint.sh \
 && chmod go+rwX -R $HOME /entrypoint.sh



VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media"]

EXPOSE 6600 6680 5555/udp

# Install snapcast Server

ARG SNAPCASTVERSION=0.11.1

RUN wget 'https://github.com/badaix/snapcast/releases/download/v'$SNAPCASTVERSION'/snapserver_'$SNAPCASTVERSION'_amd64.deb'

RUN dpkg -i --force-all 'snapserver_'$SNAPCASTVERSION'_amd64.deb'
RUN apt-get -f install -y

RUN mkdir -p /root/.config/snapcast/
COPY snapserver /etc/default/snapserver

EXPOSE 1704
EXPOSE 1705


COPY start.sh /start.sh

# Runs as mopidy user by default.
USER mopidy

ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint.sh"]
CMD ["echo 'kala'"]
#CMD ["/start.sh"]
