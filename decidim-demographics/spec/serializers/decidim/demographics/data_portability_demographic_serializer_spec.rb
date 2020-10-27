# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Demographics
    describe DataPortabilityDemographicSerializer do
      let(:resource) { create(:demographic_component) }
      let(:subject) { described_class.new(resource) }

      describe "#serialize" do
        it "includes the assembly data" do
          serialized = subject.serialize

          expect(serialized).to be_a(Hash)
          expect(serialized).to include(id)
        end
      end
    end
  end
end
