# frozen_string_literal: true
source "https://rubygems.org"

ruby "2.3.1"

gem "pg"
gem "listen"

gem "foundation_rails_helper", git: "https://github.com/sgruhier/foundation_rails_helper"
gem "rspec_junit_formatter", "0.2.3", group: :test, require: false
gem "simplecov", "~> 0.12", group: :test, require: false
gem "codecov", "~> 0.1.5", group: :test, require: false
