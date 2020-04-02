FROM centos:7

# Install mod_auth_mellon library
RUN yum install -y \
  openssl \
  httpd \
  mod_auth_mellon \
  mod_ssl \
  gettext \
  wget \
  ca-certificates \
  && yum clean all

EXPOSE 3063

ADD configure /usr/sbin/configure
ENTRYPOINT /usr/sbin/configure
