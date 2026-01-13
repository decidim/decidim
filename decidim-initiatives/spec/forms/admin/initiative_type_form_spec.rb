# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe InitiativeTypeForm do
        subject { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create(:organization) }
        let(:initiatives_type) { create(:initiatives_type, organization:) }
        let(:title) { Decidim::Faker::Localized.sentence(word_count: 5) }
        let(:promoting_committee_enabled) { true }
        let(:minimum_committee_members) { 5 }
        let(:comments_enabled) { true }
        let(:attributes) do
          {
            title:,
            description: Decidim::Faker::Localized.sentence(word_count: 25),
            online_signature_enabled: false,
            attachments_enabled: true,
            custom_signature_end_date_enabled: true,
            undo_online_signatures_enabled: false,
            area_enabled: false,
            comments_enabled:,
            promoting_committee_enabled:,
            minimum_committee_members:,
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

        context "when minimum_committee_members is blank" do
          let(:minimum_committee_members) { " " }

          it "is 2" do
            expect(subject.minimum_committee_members).to eq(2)
          end
        end

        context "when title is missing" do
          let(:title) { nil }

          it { is_expected.to be_invalid }
        end

        context "when the promoting committee is not enabled" do
          let(:promoting_committee_enabled) { false }

          it "sets 0 as minimum committee members" do
            expect(subject.minimum_committee_members).to eq(0)
          end
        end

        context "when comments are disabled" do
          let(:comments_enabled) { false }

          it { is_expected.to be_valid }
        end

        describe "banner_image validation" do
        
          context "when form is not persisted and initiative_type is nil in context" do
            let(:attributes) do
              {
                title:,
                description: Decidim::Faker::Localized.sentence(word_count: 25),
                online_signature_enabled: false,
                attachments_enabled: true,
                custom_signature_end_date_enabled: true,
                undo_online_signatures_enabled: false,
                area_enabled: false,
                comments_enabled:,
                promoting_committee_enabled:,
                minimum_committee_members:
                
              }
            end
            let(:context) do
              {
                current_organization: organization,
                current_component: nil
              
              }
            end

            it "is invalid" do
              expect(subject).to be_invalid
            end

            it "has an error on banner_image" do
              subject.valid?
              expect(subject.errors[:banner_image]).not_to be_empty
            end
          end

          context "when form is persisted (from_model)" do
            subject { described_class.from_model(initiatives_type).with_context(context) }

            let(:context) do
              {
                current_organization: organization,
                current_component: nil
              }
            end

            it "is valid even without banner_image" do
              expect(subject).to be_valid
            end
          end

          context "when initiative_type is present in context" do
            let(:attributes) do
              {
                title:,
                description: Decidim::Faker::Localized.sentence(word_count: 25),
                online_signature_enabled: false,
                attachments_enabled: true,
                custom_signature_end_date_enabled: true,
                undo_online_signatures_enabled: false,
                area_enabled: false,
                comments_enabled:,
                promoting_committee_enabled:,
                minimum_committee_members:
              
              }
            end
            let(:context) do
              {
                current_organization: organization,
                current_component: nil,
                initiative_type: initiatives_type
              }
            end

            it "is valid even without banner_image" do
              expect(subject).to be_valid
            end
          end
        end
      end
    end
  end
end
