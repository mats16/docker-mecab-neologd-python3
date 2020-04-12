FROM python:3.8.2 as builder

WORKDIR /tmp/neologd

RUN apt-get update && \
    apt-get install -y mecab libmecab-dev mecab-ipadic-utf8 && \
    apt-get install -y git make curl xz-utils file sudo && \
    git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git . && \
    ./bin/install-mecab-ipadic-neologd -n -y

FROM python:3.8.2

LABEL maintainer "mats16 <mats.kazuki@gmail.com>"

RUN apt-get update && \
    apt-get install -y mecab libmecab-dev mecab-ipadic-utf8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd/ /var/lib/mecab/dic/ipadic-neologd/

COPY src/requirements.txt ./requirements.txt
RUN pip install -r requirements.txt

ARG UID=1000
ARG USERNAME=mecab
RUN useradd -m -u ${UID} ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}

COPY src/ ./

ENV LANG C.UTF-8
EXPOSE 9090
CMD ["uwsgi", "--http", ":9090",  "--wsgi-file", "server.py", "--thunder-lock", "--enable-threads", "--threads", "2", "--http-auto-gzip", "--http-keepalive", "--http-timeout", "120", "--add-header", "Connection:Keep-Alive"]
