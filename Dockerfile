FROM ruby:3.2.2

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set frozen false
RUN bundle install
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
	&& apt-get update -qq \
	&& apt-get install -y nodejs postgresql-client \
	# && npm install --global yarn \
	&& rm -rf /var/lib/apt/lists/*

# フォントをインストールする。
# RUN apt-get update &&\
# 	apt-get install -y wget &&\
# 	apt-get install -y zip unzip &&\
# 	apt-get install -y fontconfig
# RUN wget https://moji.or.jp/wp-content/ipafont/IPAexfont/IPAexfont00301.zip
# RUN unzip IPAexfont00301.zip
# RUN mkdir -p /usr/share/fonts/ipa
# RUN cp IPAexfont00301/*.ttf /usr/share/fonts/ipa
# RUN fc-cache -fv

# RUN apt-get install -y fonts-ipafont \
# 	&& apt-get install -y fonts-ipafont-gothic fonts-ipafont-mincho
# COPY fonts.conf /etc/fonts/local.conf

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

COPY . .

CMD ["foreman", "start"]
