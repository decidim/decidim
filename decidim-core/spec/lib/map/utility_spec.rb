# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    describe Utility do
      include_context "with map utility" do
        subject { utility }
      end

      describe "#initialize" do
        it "sets the configuration organization as expected" do
          expect(subject.organization).to be(organization)
        end

        it "sets the configuration locale as expected" do
          expect(subject.locale).to be(locale)
        end

        it "sets the configuration object as expected" do
          expect(subject.configuration).to be(config)
        end
      end
    end
  end
end
