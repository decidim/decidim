# frozen_string_literal: true

Dir["#{__dir__}/test/**/*.rb"]
  .reject { |f| f == "#{__dir__}/test/factories.rb" }
  .each { |f| require f }
