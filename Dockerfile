FROM buildpack-deps AS download
ARG FACTORIO_VERSION

RUN wget --no-verbose -O /tmp/factorio_headless_x64.tar.xz https://www.factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64
RUN mkdir -p /opt
RUN tar xvf /tmp/factorio_headless_x64.tar.xz -C /opt/

FROM debian AS server
LABEL maintainer="Cryowatt" Factorio.Version=${FACTORIO_VERSION}
RUN addgroup factorio; \
    useradd factorio -g factorio

COPY --from=download --chown=factorio:factorio /opt/factorio /opt/factorio
COPY --chown=factorio:factorio factorio.config /etc/factorio/config

RUN ln -s /opt/factorio/bin/x64/factorio /usr/local/bin/factorio; \
    ln -s /opt/factorio/data/ /usr/share/factorio; \
    mkdir -p /var/factorio/saves/; \
    chown -R factorio:factorio /var/factorio; \
    chown -R factorio:factorio /etc/factorio/;

USER factorio:factorio

EXPOSE 34197

ENTRYPOINT [ "/usr/local/bin/factorio", "--config", "/etc/factorio/config" ]
CMD [ "--start-server-load-latest" ]