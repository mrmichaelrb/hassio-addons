ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache lftp

# Copy data
COPY rootfs/*.sh /
RUN chmod a+x /*.sh

CMD [ "/run.sh" ]
