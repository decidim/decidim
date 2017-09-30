# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attachment, processing_uploads_for: Decidim::AttachmentUploader do
    subject { build(:attachment) }

    it { is_expected.to be_valid }

    describe "validations" do
      context "when the file is too big" do
        before do
          allow(Decidim).to receive(:maximum_attachment_size).and_return(5.megabytes)
          expect(subject.file).to receive(:size).and_return(6.megabytes)
        end

        it { is_expected.not_to be_valid }
      end

      context "when the file is a malicious image" do
        subject do
          build(
            :attachment,
            file: Rack::Test::UploadedFile.new(attachment_path, "image/jpg")
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
        expect(subject.thumbnail_url).to be
      end

      it "has a big version" do
        expect(subject.big_url).to be
      end

      describe "photo?" do
        it "returns true" do
          expect(subject.photo?).to eq(true)
        end
      end

      describe "document?" do
        it "returns false" do
          expect(subject.document?).to eq(false)
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
          expect(subject.photo?).to eq(false)
        end
      end

      describe "document?" do
        it "returns true" do
          expect(subject.document?).to eq(true)
        end
      end
    end
  end
end
