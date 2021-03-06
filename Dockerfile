FROM nginx:alpine

MAINTAINER Julio Gutierrez <bubuntux@gmail.com>

ARG version
ARG GPG_KEY=5EA7E0F70461A3BCBEBE4D5EF6151806032026F9
RUN if [ -z "$version" ]; then echo >&2 "error: build argument 'version' is required" && exit 1; fi &&\
    apk add --no-cache --virtual .build-deps curl gnupg &&\
    curl -sSL https://github.com/vector-im/riot-web/releases/download/${version}/riot-${version}.tar.gz -o riot-web.tar.gz &&\
	  curl -sSL https://github.com/vector-im/riot-web/releases/download/${version}/riot-${version}.tar.gz.asc -o riot-web.tar.gz.asc &&\
    for server in \
			hkp://keyserver.ubuntu.com:80 \
			hkp://p80.pool.sks-keyservers.net:80 \
			ha.pool.sks-keyservers.net \
		; do \
			echo "Fetching GPG key $GPG_KEY from $server"; \
			gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEY" && break; \
		done &&\ 
    gpg --batch --verify riot-web.tar.gz.asc riot-web.tar.gz &&\
	  tar -xzf riot-web.tar.gz &&\
	  mv riot-${version} /etc/riot-web &&\
	  cp /etc/riot-web/config.sample.json /etc/riot-web/config.json &&\
	  rm -rf /usr/share/nginx/html && ln -s /etc/riot-web /usr/share/nginx/html &&\
	  rm riot-web.tar.gz* &&\
	  apk del .build-deps
