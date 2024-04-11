# Start from the official ruby base image
FROM ruby:3.2.0

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs build-essential libpq-dev

# Set the work directory
WORKDIR /app

# Copy over your gemfile
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

# Install gems
RUN bundle install

# Copy the rest of your app's source code
COPY . /app

# Expose port 3000 to the Docker host, so we can access our app from outside
EXPOSE 3000

# The command to start your app
CMD ["rails", "server", "-b", "0.0.0.0"]