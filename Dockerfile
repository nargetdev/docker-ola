FROM debian:9-slim

ENV TERM linux
ENV ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y ola \
    # Clean caches for a smaller build.
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# COPY ./vendor/bin/wait-for-it /ola/bin/wait-for-it
# RUN chown -R :olad /ola/bin
# RUN chmod -R ug+rx /ola/bin
COPY ./ftdi.rules /etc/udev/rules.d/ftdi.rules

# The ola package creates an "olad" user and sets its home, but fails to create the directory.
RUN mkdir /usr/lib/olad \
    && chown olad:olad -R /usr/lib/olad \
    # Assign the "olad" user to the "olad" group.
    && usermod -aG olad olad \
    # Allow OLA to be run by anyone in the "olad" group.
    && chown root:olad /usr/bin/olad \
    && chmod ug+rwx /usr/bin/olad

USER olad

RUN olad -f && sleep 1 \
    # Disable all OLA plugins for a clean slate, without plugin conflicts.
    && bash -c 'for pid in {1..99}; do ola_plugin_state -p $pid -s disabled &>/dev/null; done'

# COPY ola-e131.conf 	/usr/lib/olad/.ola/ola-e131.conf
COPY ola-openpixelcontrol.conf 	/usr/lib/olad/.ola/ola-openpixelcontrol.conf
# COPY ola-artnet.conf /usr/lib/olad/.ola/ola-artnet.conf

# RUN ola_patch  -d 1 -p 0 -u 1 -i

COPY start.sh .

EXPOSE 9010 9090 7890 6454 5568

CMD ["/bin/bash", "start.sh"]