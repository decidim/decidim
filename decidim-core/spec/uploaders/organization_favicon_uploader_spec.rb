# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OrganizationFaviconUploader do
    subject { uploader }

    let(:uploader) { described_class.new(model, mounted_as) }
    let(:model) { create(:organization) }
    let(:mounted_as) { :favicon }

    describe "#extension_allowlist" do
      subject { uploader.extension_allowlist }

      it "returns the custom allowed extensions" do
        expect(subject).to eq(%w(png jpg jpeg webp ico))
      end
    end

    describe "#content_type_allowlist" do
      subject { uploader.content_type_allowlist }

      it "returns the correct MIME types" do
        expect(subject).to eq(%w(image/png image/jpeg image/webp image/vnd.microsoft.icon))
      end
    end
  end
end
