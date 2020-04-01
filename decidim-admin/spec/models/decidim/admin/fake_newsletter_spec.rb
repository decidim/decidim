# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::FakeNewsletter do
  subject { described_class.new(organization, manifest) }

  let(:organization) { create :organization }
  let(:manifest) do
    Decidim
      .content_blocks
      .for(:newsletter_template)
      .find { |manifest| manifest.name.to_s == "basic_only_text" }
  end

  describe "sent_at" do
    it "is nil" do
      expect(subject.sent_at).to be_nil
    end
  end

  describe "id" do
    it "is 1" do
      expect(subject.id).to eq(1)
    end
  end

  describe "template" do
    it "builds a content block with preview data" do
      expect(subject.template).to be_kind_of(Decidim::ContentBlock)
      expect(subject.template).not_to be_persisted
      expect(subject.template.settings.body).to include("Dummy text for body")
    end
  end
end
