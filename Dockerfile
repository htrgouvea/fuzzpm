FROM kalilinux/kali-rolling:latest

WORKDIR /home/
EXPOSE 1337 9090

RUN apt update && apt list --upgradable && apt -qy dist-upgrade

RUN apt install -qy python3 python3-pip
RUN apt install -qy unzip fcrackzip hydra
RUN apt install -qy wpscan sqlmap hashid
RUN apt install -qy john amass weevely exploitdb
RUN apt install -qy libldns-dev libdbd-mysql-perl libwww-perl libnet-dns-perl
RUN apt install -qy golang metasploit-framework
RUN apt install -qy apktool jadx fping exiftool
RUN apt install -qy wordlists testssl.sh massdns
RUN apt install -qy subfinder naabu nuclei
RUN apt install -qy tcpdump

RUN apt clean && apt -y autoremove && rm -rf /var/lib/apt/lists/*

RUN gem install aquatone
RUN gunzip /usr/share/wordlists/rockyou.txt.gz

RUN cpan install Find::Lib Mojo::File YAML::Tiny