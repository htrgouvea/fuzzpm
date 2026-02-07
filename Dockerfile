FROM perl:5.42-slim

COPY . /usr/src/fuzz.pm
WORKDIR /usr/src/fuzz.pm

RUN cpanm --installdeps .

ENTRYPOINT ["perl", "./fuzzpm.pl"]
