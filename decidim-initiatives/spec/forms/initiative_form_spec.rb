# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:organization) { create(:organization) }
      let(:initiatives_type) { create(:initiatives_type, organization: organization) }
      let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }
      let(:attachment_params) { nil }

      let(:title) { Decidim::Faker::Localized.sentence(5) }
      let(:attributes) do
        {
          title: title,
          description: Decidim::Faker::Localized.sentence(25),
          type_id: initiatives_type.id,
          scope_id: scope&.scope&.id,
          signature_type: "offline",
          attachment: attachment_params
        }.merge(custom_signature_end_date)
      end
      let(:custom_signature_end_date) { {} }
      let(:context) do
        {
          current_organization: organization,
          current_component: nil,
          initiative_type: initiatives_type
        }
      end

      let(:state) { "validating" }
      let(:initiative) { create(:initiative, organization: organization, state: state, scoped_type: scope) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when title is missing" do
        let(:title) { nil }

        it { is_expected.to be_invalid }
      end

      context "when initiative type enables custom signature end date" do
        let(:initiatives_type) { create(:initiatives_type, :custom_signature_end_date_enabled, organization: organization) }

        context "when custom date is missing" do
          it { is_expected.to be_valid }
        end

        context "when custom date is in the future" do
          let(:custom_signature_end_date) { { signature_end_date: Date.tomorrow } }

          it { is_expected.to be_valid }
        end

        context "when custom date is not in the future" do
          let(:custom_signature_end_date) { { signature_end_date: Date.current } }

          it { is_expected.to be_invalid }
        end
      end

      describe "#signature_type_updatable?" do
        context "when created" do
          subject { described_class.from_model(initiative).with_context(context).signature_type_updatable? }

          let(:state) { "created" }

          it { is_expected.to eq(true) }
        end

        context "when not yet created" do
          subject { described_class.from_params(attributes).with_context(context).signature_type_updatable? }

          let(:state) { nil }

          it { is_expected.to eq(true) }
        end

        context "when any other state" do
          subject { described_class.from_model(initiative).with_context(context).signature_type_updatable? }

          it { is_expected.to eq(false) }
        end
      end

      context "when no scope is present" do
        let(:scope) { nil }

        it { is_expected.to be_valid }
      end

      context "when the attachment is present" do
        let(:attachment_params) do
          {
            title: "My attachment",
            file: Decidim::Dev.test_file("city.jpeg", "image/jpeg")
          }
        end

        it { is_expected.to be_valid }

        context "when the form has some errors" do
          let(:title) { nil }

          it "adds an error to the `:attachment` field" do
            expect(subject).not_to be_valid
            expect(subject.errors.full_messages).to match_array(["Title can't be blank", "Attachment Needs to be reattached"])
            expect(subject.errors.keys).to match_array([:title, :attachment])
          end
        end
      end
    end
  end
end
