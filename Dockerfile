FROM ubuntu:22.04

LABEL MAINTAINER Siv Chand Koripella <sivchand@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y locales && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

ENV PYENV_ROOT="/.pyenv" \
    PATH="/.pyenv/bin:/.pyenv/shims:$PATH" 

RUN apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates curl && \
    curl https://pyenv.run | bash && \
    apt-get purge -y --auto-remove ca-certificates curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \ 
    libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ONBUILD COPY python-versions.txt ./
ONBUILD RUN pyenv update 
ONBUILD RUN xargs -P 4 -n 1 pyenv install < python-versions.txt
ONBUILD RUN pyenv global $(pyenv versions --bare) 
ONBUILD RUN find $PYENV_ROOT/versions -type d '(' -name '__pycache__' -o -name 'test' -o -name 'tests' ')' -exec rm -rfv '{}' +
ONBUILD RUN find $PYENV_ROOT/versions -type f '(' -name '*.py[co]' -o -name '*.exe' ')' -exec rm -fv '{}' + 
ONBUILD RUN mv -v -- /python-versions.txt $PYENV_ROOT/version
