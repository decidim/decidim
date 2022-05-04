# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attachment do
    subject { build(:attachment) }

    let(:organization) { subject.organization }

    it { is_expected.to be_valid }

    describe "validations" do
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
            :attachment,
            file: ActiveStorage::Blob.create_and_upload!(
              io: File.open(attachment_path),
              filename: "image.jpeg",
              content_type: "image/jpeg"
            )
          )
        end

        let(:attachment_path) { Decidim::Dev.asset("malicious.jpg") }

        it { is_expected.not_to be_valid }
      end
    end

    describe "file_type" do
      it "returns the file extension" do
        expect(subject.file_type).to eq("jpeg")
      end
    end

    context "when it has an image" do
      subject { build(:attachment, :with_image) }

      it "has a thumbnail" do
        expect(subject.thumbnail_url).not_to be_nil
      end

      it "has a big version" do
        expect(subject.big_url).not_to be_nil
      end

      describe "photo?" do
        it "returns true" do
          expect(subject.photo?).to be(true)
        end
      end

      describe "document?" do
        it "returns false" do
          expect(subject.document?).to be(false)
        end
      end
    end

    context "when it has a document" do
      subject { build(:attachment, :with_pdf) }

      it "does not have a thumbnail" do
        expect(subject.thumbnail_url).to be_nil
      end

      it "does not have a big version" do
        expect(subject.big_url).to be_nil
      end

      describe "photo?" do
        it "returns false" do
          expect(subject.photo?).to be(false)
        end
      end

      describe "document?" do
        it "returns true" do
          expect(subject.document?).to be(true)
        end
      end
    end
  end
end
