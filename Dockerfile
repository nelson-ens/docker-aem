FROM base-jdk11_aem-base

LABEL org.opencontainers.image.authors="nelson@ensemble.com"

ARG AEM_VERSION="2022.1.6228.20220123T154100Z-220100"

## ARG AEM_JVM_OPTS="-server -Xms1024m -Xmx1024m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0"
## ARG AEM_JVM_OPTS="${AEM_JVM_OPTS} -XX:+UseParallelGC --add-opens=java.desktop/com.sun.imageio.plugins.jpeg=ALL-UNNAMED --add-opens=java.base/sun.net.www.protocol.jrt=ALL-UNNAMED --add-opens=java.naming/javax.naming.spi=ALL-UNNAMED --add-opens=java.xml/com.sun.org.apache.xerces.internal.dom=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.loader=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED -Dnashorn.args=--no-deprecation-warning"
ARG AEM_JVM_OPTS="-server -Xms2048m -Xmx4096m -XX:PermSize=256m -XX:MaxPermSize=1024m -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=58242 -Djava.awt.headless=true"
ARG AEM_JVM_OPTS="${AEM_JVM_OPTS}"

ARG AEM_START_OPTS="start -c /mnt/aem/crx-quickstart -p 8080 -Dsling.properties=/mnt/aem/crx-quickstart/conf/sling.properties -Dadmin.password.file=/mnt/aem/passwordfile.properties -nointeractive"
ARG AEM_JARFILE="/mnt/aem/crx-quickstart/app/cq-quickstart-cloudready-${AEM_VERSION}-standalone-quickstart.jar"
ARG AEM_RUNMODE="-Dsling.run.modes=author,crx3,crx3tar"
ARG PACKAGE_PATH="/mnt/aem/crx-quickstart/install"

ENV AEM_JVM_OPTS="${AEM_JVM_OPTS}" \
    AEM_START_OPTS="${AEM_START_OPTS}"\
    AEM_JARFILE="${AEM_JARFILE}" \
    AEM_RUNMODE="${AEM_RUNMODE}"

COPY scripts/*.sh /mnt/aem/
COPY jar/aem-sdk-quickstart-${AEM_VERSION}.jar /mnt/aem/aem-quickstart.jar
COPY jar/license.properties /mnt/aem/license.properties
COPY jar/passwordfile.properties /mnt/aem/passwordfile.properties

#ensure script has exec permissions
RUN chmod +x /mnt/aem/*.sh

WORKDIR /mnt/aem

#unpack the jar
RUN java -jar aem-quickstart.jar -unpack && \
    rm aem-quickstart.jar

#COPY dist/install.first/*.config /mnt/aem/crx-quickstart/install/
#COPY dist/install.first/logs/*.config /mnt/aem/crx-quickstart/install/
COPY dist/install.first/conf/sling.properties /mnt/aem/crx-quickstart/conf/sling.properties

COPY packages/ $PACKAGE_PATH/

#expose port
EXPOSE 8080 58242 57345 57346

VOLUME ["/mnt/aem/crx-quickstart/repository", "/mnt/aem/crx-quickstart/logs", "/mnt/aem/backup"]

#make java pid 1
ENTRYPOINT ["/mnt/aem/run-tini.sh"]
