FROM bitwarden/server:beta

WORKDIR /app
COPY ./dist .

EXPOSE 80

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
