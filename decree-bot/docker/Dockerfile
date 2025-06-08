FROM alpine:3.18

RUN apk add --no-cache curl bash

WORKDIR /app
COPY scripts/post_decree.sh /app/post_decree.sh
COPY k8s/001_roman_theme.json /app/decrees/001_roman_theme.json
RUN chmod +x /app/post_decree.sh

CMD ["/app/post_decree.sh", "001_roman_theme.json"]
