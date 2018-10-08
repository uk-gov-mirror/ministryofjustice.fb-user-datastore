FROM ministryofjustice/ruby:2.5.1

RUN apt-get update && apt-get install -y nodejs postgresql-contrib libpq-dev

ENV RAILS_ROOT /var/www/fb-user-datastore
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

COPY Gemfile.lock Gemfile ./
RUN gem install bundler
RUN bundle install --jobs 20 --retry 5

COPY . .
ADD . $RAILS_ROOT

# install kubectl as described at
# https://kubernetes.io/docs/tasks/tools/install-kubectl/
RUN apt-get update && apt-get install -y apt-transport-https
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN touch /etc/apt/sources.list.d/kubernetes.list
RUN echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl


# allow access to port 3000
ENV APP_PORT 3000
EXPOSE $APP_PORT

# run the rails server
ARG RAILS_ENV=production
CMD bundle exec rails s -e ${RAILS_ENV} -p ${APP_PORT} --binding=0.0.0.0
