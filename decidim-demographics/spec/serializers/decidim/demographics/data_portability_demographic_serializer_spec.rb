# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Demographics
    describe DataPortabilityDemographicSerializer do
      let(:resource) { create(:demographic) }
      let(:subject) { described_class.new(resource) }

      describe "#serialize" do
        it "includes the assembly data" do
          serialized = subject.serialize

          expect(serialized).to be_a(Hash)
          expect(serialized).to include(:age)
          expect(serialized).to include(:nationalities)
          expect(serialized).to include(:gender)
          expect(serialized).to include(:attended_before)
          expect(serialized).to include(:current_occupations)
          expect(serialized).to include(:education_age_stop)
          expect(serialized).to include(:id)
          expect(serialized).to include(:living_condition)
          expect(serialized).to include(:newsletter_sign_in)
          expect(serialized).to include(:newsletter_subscribe)
          expect(serialized).to include(:residences)
          expect(serialized).to include(:user)
        end
      end
    end
  end
end
