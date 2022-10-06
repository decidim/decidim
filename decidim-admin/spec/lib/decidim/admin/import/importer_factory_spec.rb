# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::Import::ImporterFactory do
  describe ".build" do
    let(:file) { double }
    let(:mime_type) { double }
    let(:reader) { double }
    let(:context) { double }
    let(:creator) { double }

    context "when reader exists" do
      it "creates a new importer with the correct reader" do
        allow(Decidim::Admin::Import::Readers).to receive(
          :search_by_mime_type
        ).with(mime_type).and_return(reader)
        expect(Decidim::Admin::Import::Importer).to receive(:new).with(
          file:,
          reader:,
          creator:,
          context:
        )
        described_class.build(file, mime_type, context:, creator:)
      end
    end

    context "when reader does not exist" do
      it "raises a NotImplementedError" do
        allow(Decidim::Admin::Import::Readers).to receive(
          :search_by_mime_type
        ).with(mime_type).and_return(nil)
        expect do
          described_class.build(file, mime_type, context:, creator:)
        end.to raise_error(NotImplementedError)
      end
    end
  end
end
