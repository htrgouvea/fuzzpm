FROM perl:5.40

COPY . /usr/src/fuzz.pm
WORKDIR /usr/src/fuzz.pm

RUN cpanm --installdeps .

ENTRYPOINT ["perl", "./fuzzpm.pl"]