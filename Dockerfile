FROM frolvlad/alpine-glibc
ARG FACTORIO_VERSION
RUN apk --no-cache add ca-certificates wget; \
    mkdir -p /opt; \
    wget -O /tmp/factorio_headless_x64.tar.xz https://www.factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64; \
    tar xvf /tmp/factorio_headless_x64.tar.xz -C /opt/; \
    rm /tmp/factorio_headless_x64.tar.xz; \
    apk --no-cache del ca-certificates wget;
    
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY factorio.config /etc/factorio/config

RUN addgroup factorio; \
    adduser factorio -DG factorio; \
    ln -s /opt/factorio/bin/x64/factorio /usr/local/bin/factorio; \
    ln -s /opt/factorio/data/ /usr/share/factorio; \
    mkdir -p /var/factorio/saves/; \
    chown factorio:factorio /usr/local/bin/entrypoint.sh; \
    chown factorio:factorio /usr/local/bin/factorio; \
    chown -R factorio:factorio /var/factorio; \
    chown -R factorio:factorio /etc/factorio/;

USER factorio
ENTRYPOINT /usr/local/bin/entrypoint.sh
EXPOSE 34197
LABEL maintainer "Cryowatt"
LABEL version=${FACTORIO_VERSION}
LABEL source=http://www.factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64