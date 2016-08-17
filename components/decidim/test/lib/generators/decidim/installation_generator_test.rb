require 'test_helper'
require 'generators/installation/installation_generator'

module Decidim
  class InstallationGeneratorTest < Rails::Generators::TestCase
    tests InstallationGenerator
    destination Rails.root.join('tmp/generators')
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end
