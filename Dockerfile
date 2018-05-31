FROM alpine:3.7
MAINTAINER Jason Pereira <jason.pereira@sohonet.com>

# Version of RabbitMQ to install
ENV RABBITMQ_VERSION=3.6.15
ENV PLUGIN_BASE=v3.6.x
ENV AUTOCLUSTER_VERSION=0.10.0
ENV DELAYED_MESSAGE_VERSION=0.0.1
ENV MESSAGE_TIMESTAMP_VERSION=3.6.x-3195a55a

RUN \
  apk --update add bash coreutils curl erlang erlang-asn1 erlang-crypto erlang-eldap erlang-erts erlang-inets erlang-mnesia erlang-os-mon erlang-public-key erlang-sasl erlang-ssl erlang-syntax-tools erlang-xmerl xz bind-tools && \
  curl -sL -o /tmp/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.gz https://www.rabbitmq.com/releases/rabbitmq-server/v${RABBITMQ_VERSION}/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.xz && \
  cd /usr/lib/ && \
  tar xf /tmp/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.gz && \
  rm /tmp/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.gz && \
  mv /usr/lib/rabbitmq_server-${RABBITMQ_VERSION} /usr/lib/rabbitmq

RUN \
  curl -sL -o /usr/lib/rabbitmq/plugins/rabbitmq_delayed_message_exchange-${DELAYED_MESSAGE_VERSION}.ez  http://www.rabbitmq.com/community-plugins/${PLUGIN_BASE}/rabbitmq_delayed_message_exchange-${DELAYED_MESSAGE_VERSION}.ez && \
  curl -sL -o /usr/lib/rabbitmq/plugins/rabbitmq_message_timestamp-${MESSAGE_TIMESTAMP_VERSION}.ez https://www.rabbitmq.com/community-plugins/${PLUGIN_BASE}/rabbitmq_message_timestamp-${MESSAGE_TIMESTAMP_VERSION}.ez && \
  curl -sL -o /usr/lib/rabbitmq/plugins/autocluster-${AUTOCLUSTER_VERSION}.ez https://github.com/rabbitmq/rabbitmq-autocluster/releases/download/${AUTOCLUSTER_VERSION}/autocluster-${AUTOCLUSTER_VERSION}.ez && \
  curl -sL -o /usr/lib/rabbitmq/plugins/rabbitmq_aws-${AUTOCLUSTER_VERSION}.ez https://github.com/rabbitmq/rabbitmq-autocluster/releases/download/${AUTOCLUSTER_VERSION}/rabbitmq_aws-${AUTOCLUSTER_VERSION}.ez

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN adduser -s /bin/bash -D -h /var/lib/rabbitmq rabbitmq

ADD erlang.cookie /var/lib/rabbitmq/.erlang.cookie
ADD rabbitmq.config /usr/lib/rabbitmq/etc/rabbitmq/rabbitmq.config

# Environment variables required to run
ENV ERL_EPMD_PORT=4369
ENV HOME /var/lib/rabbitmq
ENV PATH /usr/lib/rabbitmq/bin:/usr/lib/rabbitmq/sbin:$PATH

ENV RABBITMQ_LOGS=-
ENV RABBITMQ_SASL_LOGS=-
ENV RABBITMQ_DIST_PORT=25672
ENV RABBITMQ_SERVER_ERL_ARGS="+K true +A128 +P 1048576 -kernel inet_default_connect_options [{nodelay,true}]"
ENV RABBITMQ_MNESIA_DIR=/var/lib/rabbitmq/mnesia
ENV RABBITMQ_PID_FILE=/var/lib/rabbitmq/rabbitmq.pid
ENV RABBITMQ_PLUGINS_DIR=/usr/lib/rabbitmq/plugins
ENV RABBITMQ_PLUGINS_EXPAND_DIR=/var/lib/rabbitmq/plugins

# Fetch the external plugins and setup RabbitMQ
RUN \
  apk --purge del curl tar gzip xz && \
  chown rabbitmq /var/lib/rabbitmq/.erlang.cookie /var/lib/rabbitmq /usr/lib/rabbitmq && \
  chmod 0600 /var/lib/rabbitmq/.erlang.cookie && \
  rabbitmq-plugins enable --offline \
        autocluster \
        rabbitmq_delayed_message_exchange \
        rabbitmq_management \
        rabbitmq_management_agent \
        rabbitmq_management_visualiser \
        rabbitmq_consistent_hash_exchange \
        rabbitmq_federation \
        rabbitmq_federation_management \
        rabbitmq_message_timestamp \
        rabbitmq_recent_history_exchange \
        rabbitmq_sharding \
        rabbitmq_web_dispatch \
        rabbitmq_top && \
  rabbitmq-plugins list

EXPOSE 1883 4369 5671 5672 15672 25672

USER rabbitmq
CMD /usr/lib/rabbitmq/sbin/rabbitmq-server
