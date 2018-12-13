# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe InitiativeTypeForm do
        subject { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create :organization }
        let(:initiatives_type) { create(:initiatives_type, organization: organization) }
        let(:title) { Decidim::Faker::Localized.sentence(5) }
        let(:min_committee_members) { 5 }
        let(:attributes) do
          {
            title: title,
            description: Decidim::Faker::Localized.sentence(25),
            online_signature_enabled: false,
            min_committee_members: min_committee_members,
            banner_image: Decidim::Dev.test_file("city2.jpeg", "image/jpeg")
          }
        end
        let(:context) do
          {
            current_organization: initiatives_type.organization,
            current_component: nil
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when min_committee_members is blank" do
          let(:min_committee_members) { " " }

          it "is nullified" do
            expect(subject.min_committee_members).to be_nil
          end
        end

        context "when title is missing" do
          let(:title) { nil }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
