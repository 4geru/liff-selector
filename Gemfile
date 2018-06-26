source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in liff_selector.gemspec
gemspec
gem 'rest-client'
gem 'dotenv'

group :test do
  # HTTP requests用のモックアップを作ってくれる
  gem 'rspec'
  gem 'webmock'
end