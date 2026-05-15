# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Decidim::AttachmentForm do
    subject(:form) do
      described_class.from_params(
        attributes
      ).with_context(
        attached_to:,
        current_organization: organization
      )
    end

    let(:organization) { create(:organization) }
    let(:component) { create(:debates_component, organization:) }
    let(:attached_to) { create(:debate, component:) }
    let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

    context "when everything is ok" do
      let(:attributes) do
        {
          "attachment" => {
            "file" => file,
            "title" => "Valid Title"
          }
        }
      end

      it { is_expected.to be_valid }
    end

    context "without a file" do
      let(:attributes) do
        {
          "attachment" => {
            "title" => "Title Without File"
          }
        }
      end

      it { is_expected.to be_valid }
    end

    context "when the title is not present" do
      let(:attributes) do
        {
          "attachment" => {
            "file" => file
          }
        }
      end

      it { is_expected.not_to be_valid }
    end

    context "when the file is not present" do
      let(:attributes) do
        {
          "attachment" => {}
        }
      end

      it { is_expected.to be_valid }
    end

    context "with an invalid file type" do
      let(:invalid_file) { Decidim::Dev.test_file("participatory_text.odt", "application/vnd.oasis.opendocument.text") }
      let(:attributes) do
        {
          "attachment" => {
            "file" => invalid_file,
            "title" => "Title With Invalid File"
          }
        }
      end

      it { is_expected.not_to be_valid }
    end
  end
end
