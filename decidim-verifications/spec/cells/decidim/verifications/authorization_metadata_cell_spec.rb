# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::AuthorizationMetadataCell, type: :cell do
  controller Decidim::ApplicationController

  subject { cell("decidim/verifications/authorization_metadata", model).call }

  let(:metadata) { nil }
  let(:model) { create(:authorization, :granted, metadata:, name: "another_dummy_authorization_handler") }

  it "renders the information text" do
    expect(subject).to have_text("This is the data of the current verification:")
  end

  context "when rendering with no metadata" do
    it "renders the link wrapper" do
      expect(subject).to have_text("No data stored")
    end
  end

  context "when rendering with existing metadata" do
    let(:metadata) do
      { postal_code: "123456" }
    end

    it "renders the metadata" do
      expect(subject).to have_text("Postal code")
      expect(subject).to have_text("123456")
    end

    context "when metadata has an 'extras' key" do
      before do
        metadata[:extras] = { gender: :gender_value }
      end

      it "ignores the content of the 'extras' key" do
        expect(subject).to have_no_text("gender")
      end
    end
  end
end
