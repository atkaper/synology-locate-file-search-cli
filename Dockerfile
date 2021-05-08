FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y --no-install-recommends install tzdata mlocate

COPY indexer.sh /indexer.sh
COPY updatedb.sh /updatedb.sh
RUN chmod 755 /indexer.sh /updatedb.sh
WORKDIR /

CMD /indexer.sh
