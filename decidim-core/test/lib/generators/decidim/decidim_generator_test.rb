# frozen_string_literal: true
require "test_helper"
require "generators/decidim/decidim_generator"

module Decidim
  class DecidimGeneratorTest < Rails::Generators::TestCase
    tests DecidimGenerator
    destination Rails.root.join("tmp/generators")
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end
