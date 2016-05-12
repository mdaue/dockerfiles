FROM centos:latest
MAINTAINER Matt Daue mdaue@carbyne.solutions

RUN yum update -y && yum clean all
RUN yum install -y squid
ADD start_proxy.sh /start_proxy.sh

EXPOSE 3128

VOLUME /etc/squid

CMD ["/start_proxy.sh"]
