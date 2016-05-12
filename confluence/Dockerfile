FROM java:8

# TODO:
# 1. Change the changeit keystorepass for better security
# 2. Change the COMMON NAME variable to represent your environment

# Setup useful environment variables
ENV CONF_HOME     /var/atlassian/confluence
ENV CONF_INSTALL  /opt/atlassian/confluence
ENV CONF_VERSION  5.9.8
ENV JAVA_HOME /usr
ENV COMMON_NAME  # Change me

# Install Atlassian Confluence and helper tools and setup initial home
# directory structure.
RUN set -x \
    && apt-get update \
    && apt-get install --yes --no-install-recommends libtcnative-1 xmlstarlet \
    && apt-get clean \
    && mkdir -p                "${CONF_HOME}" \
    && chmod -R 700            "${CONF_HOME}" \
    && chown daemon:daemon     "${CONF_HOME}" \
    && mkdir -p                "${CONF_INSTALL}/conf" \
    && curl -Ls                "http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \
    && chmod -R 700            "${CONF_INSTALL}/conf" \
    && chmod -R 700            "${CONF_INSTALL}/temp" \
    && chmod -R 700            "${CONF_INSTALL}/logs" \
    && chmod -R 700            "${CONF_INSTALL}/work" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/conf" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/temp" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/logs" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/work" \
    && echo -e                 "\nconfluence.home=$CONF_HOME" >> "${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties"

RUN set -x \
    &&  ${JAVA_HOME}/bin/keytool \
        -genkey \
        -storepass "changeit" \
        -keypass "changeit" \
        -noprompt \
        -dname "CN=${COMMON_NAME}, OU=NoOU, O=NoO, L=NoL, S=NoS, C=NO" \
        -alias tomcat \
        -keyalg RSA

RUN set -x \
    && xmlstarlet              ed --inplace \
        --delete               "Server/@debug" \
        --delete               "Server/Service/Connector/@debug" \
        --delete               "Server/Service/Connector/@useURIValidationHack" \
        --delete               "Server/Service/Connector/@minProcessors" \
        --delete               "Server/Service/Connector/@maxProcessors" \
        --delete               "Server/Service/Engine/@debug" \
        --delete               "Server/Service/Engine/Host/@debug" \
        --delete               "Server/Service/Engine/Host/Context/@debug" \
        --update               "Server/Service/Connector[@port='8090']/@port" --value "80" \
        --subnode              "Server/Service" -t elem -n ConnectorHTTPS -v "" \
        --append               "//ConnectorHTTPS" -t attr -n port -v '443' \
        --append               "//ConnectorHTTPS" -t attr -n maxHttpHeaderSize -v '8192' \
        --append               "//ConnectorHTTPS" -t attr -n maxThreads -v '150' \
        --append               "//ConnectorHTTPS" -t attr -n minSpareThreads -v '25' \
        --append               "//ConnectorHTTPS" -t attr -n protocol -v 'org.apache.coyote.http11.Http11NioProtocol' \
        --append               "//ConnectorHTTPS" -t attr -n enableLookups -v 'false' \
        --append               "//ConnectorHTTPS" -t attr -n disableUploadTimeout -v 'true' \
        --append               "//ConnectorHTTPS" -t attr -n acceptCount -v '100' \
        --append               "//ConnectorHTTPS" -t attr -n scheme -v 'https' \
        --append               "//ConnectorHTTPS" -t attr -n secure -v 'true' \
        --append               "//ConnectorHTTPS" -t attr -n clientAuth -v 'false' \
        --append               "//ConnectorHTTPS" -t attr -n sslProtocols -v 'TLSv1,TLSv1.1,TLSv1.2' \
        --append               "//ConnectorHTTPS" -t attr -n sslEnabledProtocols -v 'TLSv1,TLSv1.1,TLSv1.2' \
        --append               "//ConnectorHTTPS" -t attr -n SSLEnabled -v 'true' \
        --append               "//ConnectorHTTPS" -t attr -n URIEncoding -v 'UTF-8' \
        --append               "//ConnectorHTTPS" -t attr -n keystorePass -v "changeit" \
        -r                     "//ConnectorHTTPS" -v Connector \
                               "${CONF_INSTALL}/conf/server.xml"

RUN echo "Installing: ${CONF_VERSION}"
# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
# TODO: uncomment if any port >80/443 is chosen (like 8090)
#USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 80 443

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/confluence"]

# Set the default working directory as the Confluence home directory.
WORKDIR ${CONF_HOME}

ADD start.sh /start.sh

# Run Atlassian Confluence as a foreground process by default.
CMD ["/start.sh"]
