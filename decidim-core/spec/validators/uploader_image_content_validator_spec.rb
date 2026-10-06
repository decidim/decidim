# frozen_string_literal: true

require "spec_helper"

describe UploaderImageContentValidator do
  subject { validatable.new(upload:) }

  let(:validatable) { base_validatable }
  let(:base_validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      # We need to pass the correct uploader for the "upload" attribute for it
      # to provide the image settings required for the validator.
      def self.attached_config
        {
          upload: { uploader: Decidim::ImageUploader }
        }
      end

      include Decidim::AttributeObject::Model
      include ActiveModel::Validations
      include Decidim::HasUploadValidations

      attribute :upload

      validates :upload, uploader_image_content: true
    end
  end

  shared_examples "a valid image" do
    it { is_expected.to be_valid }
  end

  shared_examples "a spoofed image" do
    it { is_expected.not_to be_valid }

    it "adds the correct error" do
      subject.valid?
      expect(subject.errors[:upload]).to contain_exactly("The file is not a valid image")
    end
  end

  context "when the file is a valid image" do
    context "with a JPEG" do
      let(:upload) { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }

      it_behaves_like "a valid image"
    end

    context "with a PNG" do
      let(:upload) { Decidim::Dev.test_file("icon.png", "image/png") }

      it_behaves_like "a valid image"
    end

    context "with a GIF" do
      let(:upload) { Decidim::Dev.test_file("test.gif", "image/gif") }

      it_behaves_like "a valid image"
    end

    context "with a HEIF" do
      let(:upload) { Decidim::Dev.test_file("test.heic", "image/heic") }

      it_behaves_like "a valid image"
    end

    context "with an AVIF" do
      let(:upload) { Decidim::Dev.test_file("test.avif", "image/avif") }

      it_behaves_like "a valid image"
    end
  end

  context "when the file is a spoofed image" do
    context "with MATLAB content and a PNG content type" do
      let(:upload) { Decidim::Dev.test_file("spoofed_image.png", "image/png") }

      it_behaves_like "a spoofed image"
    end

    context "with HTML content and a PNG content type" do
      let(:upload) { Decidim::Dev.test_file("spoofed_image_html.png", "image/png") }

      it_behaves_like "a spoofed image"
    end

    context "with MATLAB content and a JPEG content type" do
      let(:upload) { Decidim::Dev.test_file("spoofed_image.png", "image/jpeg") }

      it_behaves_like "a spoofed image"
    end

    context "with a video (ftyp) file and an image content type" do
      let(:upload) { Decidim::Dev.test_file("video.mp4", "image/png") }

      it_behaves_like "a spoofed image"
    end
  end

  context "when the file is not an image" do
    let(:upload) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

    it "is not validated by this validator" do
      expect(subject).to be_valid
    end
  end

  context "when the file is an ActionDispatch::Http::UploadedFile" do
    let(:upload) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: File.open(Decidim::Dev.asset("spoofed_image.png")),
        type: "image/png",
        filename: "spoofed_image.png"
      )
    end

    it_behaves_like "a spoofed image"
  end

  context "when the file is an ActiveStorage::Attached" do
    subject { record }

    let(:record) { validatable.new(upload: blob) }
    let(:validatable) do
      Class.new(base_validatable) do
        attr_reader :upload_blob

        def upload
          @upload ||= ActiveStorage::Attached::One.new(:upload, self)
        end

        def upload=(blob)
          @upload_blob = blob
        end
      end
    end
    let(:blob) do
      # `identify: false` keeps the declared content type (image/png) so that
      # the file is treated as an image, reproducing the scenario in which the
      # real content (MATLAB) does not match the declared image format.
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("spoofed_image.png")),
        filename: "spoofed_image.png",
        content_type: "image/png",
        identify: false
      )
    end
    let(:attachment) do
      ActiveStorage::Attachment.create!(
        name: "upload",
        record: create(:dummy_resource),
        blob:
      )
    end

    before do
      allow(record.upload).to receive(:blank?).and_return(false)
      allow(record.upload).to receive(:attachment).and_return(attachment)
    end

    it_behaves_like "a spoofed image"
  end

  context "when the file is an ActiveStorage::Attached pending in a new record" do
    subject { record }

    let(:record) { validatable.new(upload:) }
    let(:validatable) do
      # Mimics the deferral of ActiveStorage, which keeps the attachable in the
      # record's attachment changes and only persists the blob when the record
      # is saved.
      Class.new(base_validatable) do
        attr_reader :attachment_changes

        def initialize(*)
          @attachment_changes = {}
          super
        end

        def attachment_reflections
          { "upload" => OpenStruct.new(options: {}) }
        end

        def upload
          @upload ||= ActiveStorage::Attached::One.new("upload", self)
        end

        def upload=(attachable)
          attachment_changes["upload"] = ActiveStorage::Attached::Changes::CreateOne.new("upload", self, attachable)
        end
      end
    end
    let(:pending_attachment) do
      ActiveStorage::Attachment.new(
        name: "upload",
        record: create(:dummy_resource),
        blob: record.attachment_changes["upload"].blob
      )
    end

    before do
      allow(record.upload).to receive(:attachment).and_return(pending_attachment)
    end

    context "with a spoofed image" do
      # The magic bytes of the file are unknown, so the content type of the
      # pending blob is identified from the file name extension (image/png).
      let(:upload) { Decidim::Dev.test_file("spoofed_image_binary.png", "image/png") }

      it_behaves_like "a spoofed image"
    end

    context "with a valid image" do
      let(:upload) { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }

      it_behaves_like "a valid image"
    end
  end
end
