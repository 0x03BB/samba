FROM alpine:latest

RUN \
  apk update && \
  apk upgrade && \
  apk add \
  runit \
  samba && \
  rm -rf /var/cache/apk/*

COPY --chmod=744 entrypoint.sh /root/entrypoint.sh
COPY --chmod=744 run /root/runit/run
COPY smb.conf /root/smb.conf

ENTRYPOINT [ "/root/entrypoint.sh" ]

CMD [ "runsv", "/root/runit" ]
