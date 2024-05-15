# frozen_string_literal: true

require "spec_helper"
require "decidim/generators/test/generator_examples"

module Decidim
  describe Generators do
    include_context "when generating a new application"

    context "with an application" do
      let(:test_app) { "spec/generator_test_app" }

      after { FileUtils.rm_rf(test_app) }

      context "with --queue providers" do
        let(:command) { "decidim #{test_app} --storage s3 --queue sidekiq" }

        it_behaves_like "an application with storage and queue gems"
      end
    end
  end
end
