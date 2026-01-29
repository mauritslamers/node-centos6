FROM centos:centos6
LABEL maintainer="joe@rstudio.com"

COPY CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
COPY epel.repo /etc/yum.repos.d/epel.repo

RUN yum -y install wget curl ca-certificates kernel-headers

RUN yum -y install centos-release-scl
RUN yum -y install python27
RUN yum -y install rh-python36
RUN yum -y install devtoolset-9
RUN yum -y install git
RUN yum -y install xz

RUN wget https://vault.centos.org/7.9.2009/updates/x86_64/Packages/glibc-2.17-326.el7_9.3.x86_64.rpm
RUN wget https://vault.centos.org/7.9.2009/updates/x86_64/Packages/glibc-common-2.17-326.el7_9.3.x86_64.rpm
RUN wget https://vault.centos.org/7.9.2009/updates/x86_64/Packages/glibc-devel-2.17-326.el7_9.3.x86_64.rpm
RUN wget https://vault.centos.org/7.9.2009/updates/x86_64/Packages/glibc-headers-2.17-326.el7_9.3.x86_64.rpm
RUN wget https://vault.centos.org/7.9.2009/updates/x86_64/Packages/glibc-utils-2.17-326.el7_9.3.x86_64.rpm
RUN wget https://vault.centos.org/7.9.2009/updates/x86_64/Packages/glibc-static-2.17-326.el7_9.3.x86_64.rpm
RUN wget https://vault.centos.org/7.9.2009/updates/x86_64/Packages/nscd-2.17-326.el7_9.3.x86_64.rpm

RUN rpm -Uvh --force --nodeps glibc-2.17-326.el7_9.3.x86_64.rpm glibc-common-2.17-326.el7_9.3.x86_64.rpm glibc-devel-2.17-326.el7_9.3.x86_64.rpm glibc-headers-2.17-326.el7_9.3.x86_64.rpm
RUN rpm -Uvh --force --nodeps glibc-static-2.17-326.el7_9.3.x86_64.rpm glibc-utils-2.17-326.el7_9.3.x86_64.rpm nscd-2.17-326.el7_9.3.x86_64.rpm

COPY make-node.sh /make-node.sh

ENTRYPOINT [ "/make-node.sh" ]
