# frozen_string_literal: true

require "spec_helper"

describe Decidim::EditorImage do
  subject { editor_image }

  let(:editor_image) { build(:editor_image) }

  it { is_expected.to be_valid }

  describe "validations" do
    let(:organization) { subject.organization }

    context "when the file is too big" do
      before do
        organization.settings.tap do |settings|
          settings.upload.maximum_file_size.default = 5
        end
        allow(subject.file.blob).to receive(:byte_size).and_return(6.megabytes)
      end

      it { is_expected.not_to be_valid }
    end

    context "when the file is a malicious image" do
      subject do
        build(
          :editor_image,
          file: ActiveStorage::Blob.create_and_upload!(
            io: File.open(Decidim::Dev.asset("malicious.jpg")),
            filename: "image.jpeg",
            content_type: "image/jpeg"
          )
        )
      end

      it { is_expected.not_to be_valid }
    end
  end
end
