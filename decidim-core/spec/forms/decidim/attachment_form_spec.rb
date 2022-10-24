# frozen_string_literal: true

require "spec_helper"

describe Decidim::AttachmentForm do
  subject do
    described_class.new(
      title:,
      file:
    ).with_context(current_organization: organization)
  end

  let(:title) { "My attachment" }
  let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
  let(:organization) { create(:organization) }

  context "with correct data" do
    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when the file is present" do
    context "and the title is not present" do
      let(:title) { "" }

      it "is not valid" do
        expect(subject).not_to be_valid
      end
    end
  end

  context "when the file is not present" do
    let(:file) { nil }

    context "and the title is not present" do
      let(:title) { "" }

      it "is not valid" do
        expect(subject).to be_valid
      end
    end
  end
end
