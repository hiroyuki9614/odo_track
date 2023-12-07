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
	&& npm install --global yarn \
	&& rm -rf /var/lib/apt/lists/*


COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

COPY . .

CMD ["foreman", "start"]
