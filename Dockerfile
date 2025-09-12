FROM alpine:3.22 AS builder
ARG MDNS_REPEATER_VERSION=local
ADD mdns-repeater.c mdns-repeater.c
RUN set -ex && \
    apk add build-base
RUN gcc -o /bin/mdns-repeater mdns-repeater.c -DHGVERSION=\"${MDNS_REPEATER_VERSION}\"

FROM alpine:3.22

LABEL maintainer="Avri Chen-Roth"

# Install dependencies
RUN apk add --no-cache bash
RUN apk add --no-cache libcap
RUN apk add --no-cache su-exec

COPY scripts/ /scripts

# Copy the binary from the builder stage
COPY --from=builder /bin/mdns-repeater /bin/mdns-repeater

# Set permissions
RUN chown root:root /bin/mdns-repeater
RUN chmod 0755 /bin/mdns-repeater

# Grant the binary the capability to open raw network sockets
RUN setcap cap_net_raw=+ep /bin/mdns-repeater

ENV APP_NAME="mdns-repeater-app" \
    APP_BIN="/bin/mdns-repeater" \
    APP_USERNAME="daemon" \
    APP_GROUPNAME="daemon"

# copy run script and set permissions
COPY run.sh /app/
RUN chown -R root:root /app
RUN chmod -R 0744 /app
RUN chmod 0755 /app/run.sh

# set entrypoint and default command
ENTRYPOINT ["/app/run.sh"]
CMD ["mdns-repeater-app", "-f", "eth0", "docker0"]
