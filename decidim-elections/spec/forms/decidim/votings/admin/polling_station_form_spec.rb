# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe PollingStationForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:voting) { create(:voting) }
        let(:context) do
          {
            current_organization: organization,
            voting:
          }
        end
        let(:title) do
          Decidim::Faker::Localized.sentence(word_count: 3)
        end
        let(:location) do
          Decidim::Faker::Localized.sentence(word_count: 3)
        end
        let(:location_hints) do
          Decidim::Faker::Localized.sentence(word_count: 3)
        end
        let(:address) { "Somewhere over the rainbow" }
        let(:latitude) { 40.1234 }
        let(:longitude) { 2.1234 }

        let(:attributes) do
          {
            title_en: title[:en],
            location_en: location[:en],
            location_hints_en: location_hints[:en],
            address:
          }
        end

        before do
          stub_geocoding(address, [latitude, longitude])
        end

        it { is_expected.to be_valid }

        describe "when title is missing" do
          let(:title) { { en: nil } }

          it { is_expected.not_to be_valid }
        end

        describe "when location is missing" do
          let(:location) { { en: nil } }

          it { is_expected.not_to be_valid }
        end

        describe "when location_hints is missing" do
          let(:location_hints) { { en: nil } }

          it { is_expected.not_to be_valid }
        end

        describe "when address is missing" do
          let(:address) { nil }

          it { is_expected.not_to be_valid }
        end

        it "validates address and store its coordinates" do
          expect(subject).to be_valid
          expect(subject.latitude).to eq(latitude)
          expect(subject.longitude).to eq(longitude)
        end
      end
    end
  end
end
