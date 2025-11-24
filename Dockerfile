FROM quay.io/keycloak/keycloak:26.2.5 AS builder

ENV KC_DB=postgres \
    KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true

WORKDIR /opt/keycloak
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:26.2.5

COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENV KC_DB=postgres \
    KC_HTTP_ENABLED=true \
    KC_HOSTNAME_STRICT=false \
    KC_PROXY_HEADERS=xforwarded

USER 1000

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
  CMD curl -f http://localhost:8080/health/ready || exit 1

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]