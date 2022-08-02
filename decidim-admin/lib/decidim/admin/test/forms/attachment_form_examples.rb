# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    shared_examples_for "attachment form" do
      subject(:form) do
        described_class.from_params(
          attributes
        ).with_context(
          attached_to:,
          current_organization: organization
        )
      end

      let(:title) do
        {
          en: "My attachment",
          es: "Mi adjunto",
          ca: "EL meu adjunt"
        }
      end
      let(:description) do
        {
          en: "My attachment description",
          es: "Descripción de mi adjunto",
          ca: "Descripció del meu adjunt"
        }
      end

      let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
      let(:attachment_collection) { create(:attachment_collection, collection_for: attached_to) }
      let(:attachment_collection_id) { attachment_collection.id }
      let(:organization) { create :organization }

      let(:attributes) do
        {
          "attachment" => {
            "title_en" => title[:en],
            "title_es" => title[:es],
            "title_ca" => title[:ca],
            "description_en" => description[:en],
            "description_es" => description[:es],
            "description_ca" => description[:ca],
            "file" => file,
            "attachment_collection_id" => attachment_collection_id
          }
        }
      end

      it { is_expected.to be_valid }

      context "when the title is not present" do
        let(:title) { { en: nil } }

        it { is_expected.not_to be_valid }
      end

      context "when the file is not present" do
        let(:file) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the attachment collection is not present" do
        let(:attachment_collection_id) { nil }

        it { is_expected.to be_valid }
      end

      context "when the attachment collection belongs to another participatory process" do
        let(:other_attached_to) { create(:participatory_process) }
        let(:attachment_collection) { create(:attachment_collection, collection_for: other_attached_to) }

        it { is_expected.not_to be_valid }
      end

      describe "attachment collection" do
        subject { form.attachment_collection }

        context "when the attachment collection exists" do
          it { is_expected.to be_kind_of(Decidim::AttachmentCollection) }
        end

        context "when the attachment collection does not exist" do
          let(:attachment_collection_id) { 3456 }

          it { is_expected.to eq(nil) }
        end

        context "when the attachment collection is from another participatory process" do
          let(:attachment_collection_id) { create(:attachment_collection).id }

          it { is_expected.to eq(nil) }
        end
      end
    end
  end
end
