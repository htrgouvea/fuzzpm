FROM kalilinux/kali-rolling:latest
MAINTAINER  Heitor Gouvêa <hi@heitorgouvea.me>

WORKDIR /home/
EXPOSE 1337 9090

RUN apt -qy update
RUN apt list --upgradable
RUN apt -qy dist-upgrade

RUN apt install -qy \
	python3 \
  	python3-pip \
  	unzip \
  	wpscan \
  	sqlmap \
  	john \
	amass \
	libldns-dev \
	golang \
  	apktool \
  	exploitdb \
  	weevely \
  	fcrackzip \
  	metasploit-framework \
  	hashid \
  	jadx \
  	hydra \
  	fping \
	dirb \
  	exiftool \
  	wordlists \
	testssl.sh \
	libwww-perl \
	subfinder \
	naabu \
	nuclei \
	massdns \
	libdbd-mysql-perl \
	libnet-dns-perl \
	tcpdump

RUN apt clean 
RUN apt -y autoremove 
RUN rm -rf /var/lib/apt/lists/*

RUN export GOPATH=$HOME/go
RUN export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
RUN GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx && mv /root/go/bin/httpx /usr/bin/httpx

RUN gem install aquatone
RUN gunzip /usr/share/wordlists/rockyou.txt.gz

RUN cpan install Find::Lib Mojo::File YAML::Tiny
