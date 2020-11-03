# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Demographics
    describe DataPortabilityDemographicSerializer do
      let(:resource) { create(:encrypted_demographic) }
      let(:subject) { described_class.new(resource) }

      describe "#serialize" do
        it "includes the assembly data" do
          serialized = subject.serialize

          expect(serialized).to be_a(Hash)
          expect(serialized).to include(:age)
          expect(serialized).to include(:nationalities)
          expect(serialized).to include(:gender)
          expect(serialized).to include(:postal_code)
          expect(serialized).to include(:background)
        end
      end
    end
  end
end
