ARG TAG
FROM freechd
LABEL maintainer="Martkist Developers"
LABEL tag=${TAG}

# Install freech-html
RUN git clone https://github.com/martkist/freech-html.git /freech-html

# Configure HOME directory
# and persist freech data directory as a volume
ENV HOME /root
VOLUME /root/.freech

# Run freechd by default
ENTRYPOINT ["/freech-core/docker-entrypoint.sh"]
EXPOSE 4033
EXPOSE 4032