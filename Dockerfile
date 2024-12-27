FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y --no-install-recommends install tzdata plocate locales && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# Set charset to support utf-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY indexer.sh /indexer.sh
COPY updatedb.sh /updatedb.sh
RUN chmod 755 /indexer.sh /updatedb.sh

# Exclude recycle bin from indexing
RUN sed -i -r 's/# PRUNENAMES.*/PRUNENAMES="#recycle"/g' /etc/updatedb.conf ; cat /etc/updatedb.conf

WORKDIR /

CMD /indexer.sh
