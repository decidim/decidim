# frozen_string_literal: true

require "spec_helper"
require "decidim/generators/test/generator_examples"

module Decidim
  describe Generators do
    include_context "when generating a new application"

    context "with an application" do
      let(:test_app) { "spec/generator_test_app" }

      after { FileUtils.rm_rf(test_app) }

      context "with --edge flag" do
        let(:command) { "decidim --edge #{test_app}" }

        it_behaves_like "a new production application"
      end
    end
  end
end
