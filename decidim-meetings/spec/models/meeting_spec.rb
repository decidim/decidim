# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe Meeting do
      let(:address) { ::Faker::Lorem.sentence(3) }
      let(:meeting) { build :meeting, address: address }

      subject { meeting }

      it { is_expected.to be_valid }

      include_examples "has feature"
      include_examples "has scope"
      include_examples "has category"
      include_examples "has reference"

      context "without a title" do
        let(:meeting) { build :meeting, title: nil }

        it { is_expected.not_to be_valid }
      end

      context "when geocoding is enabled" do
        let(:address) { "Carrer del Pare Llaurador, 113" }
        let(:latitude) { 40.1234 }
        let(:longitude) { 2.1234 }

        before do
          Geocoder::Lookup::Test.add_stub(
            address,
            [{
              "latitude" => latitude,
              "longitude" => longitude
            }]
          )
        end

        it "geocodes address and find latitude and longitude" do
          subject.geocode
          expect(subject.latitude).to eq(latitude)
          expect(subject.longitude).to eq(longitude)
        end
      end

      describe "#users_to_notify_on_comment_created" do
        let!(:follows) { create_list(:follow, 3, followable: subject) }

        it "returns the followers" do
          expect(subject.users_to_notify_on_comment_created).to match_array(follows.map(&:user))
        end
      end
    end
  end
end
