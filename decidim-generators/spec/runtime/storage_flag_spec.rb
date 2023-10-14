# frozen_string_literal: true

require "spec_helper"
require "decidim/generators/test/generator_examples"

module Decidim
  describe Generators do
    include_context "when generating a new application"

    context "with an application" do
      let(:test_app) { "spec/generator_test_app" }

      after { FileUtils.rm_rf(test_app) }

      context "with wrong --storage providers" do
        let(:command) { "decidim #{test_app} --storage s3,gcs,assure" }

        it_behaves_like "an application with wrong cloud storage options"
      end

      context "with --storage providers" do
        let(:command) { "decidim #{test_app} --storage s3,gcs,azure" }

        it_behaves_like "an application with cloud storage gems"
      end
    end
  end
end
