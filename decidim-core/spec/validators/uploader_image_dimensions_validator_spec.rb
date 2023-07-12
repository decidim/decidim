# frozen_string_literal: true

require "spec_helper"

describe UploaderImageDimensionsValidator do
  subject { validatable.new(upload:) }

  let(:validatable) { base_validatable }
  let(:base_validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      # We need to pass the correct uploader for the "upload" attribute for it
      # to provide the image dimension settings required for the validator.
      def self.attached_config
        {
          upload: { uploader: Decidim::OrganizationFaviconUploader }
        }
      end

      include Decidim::AttributeObject::Model
      include ActiveModel::Validations
      include Decidim::HasUploadValidations

      attribute :upload

      validates :upload, uploader_image_dimensions: true
    end
  end

  shared_examples "working image dimensions validator" do |type|
    shared_examples "valid image type" do
      it { is_expected.to be_valid }

      # This is just to ensure the validator will actually run the validations
      # on the file in case it is changed. If this would fail, the other tests
      # would automatically pass without testing the file.
      it "requires dimensions" do
        expect(subject.attached_uploader(:upload).validable_dimensions).to be(true)
      end

      # Ensure MiniMagic is called so that the validations are actually run for
      # the same reason as above.
      it "calls MiniMagick" do
        if type == :blob
          expect(MiniMagick::Image).to receive(:read).and_call_original
        else
          expect(MiniMagick::Image).to receive(:new).and_call_original
        end

        subject.valid?
      end
    end

    context "with a JPEG" do
      let(:filename) { "avatar.jpg" }
      let(:content_type) { "image/jpeg" }

      it_behaves_like "valid image type"
    end

    context "with a PNG" do
      let(:filename) { "icon.png" }
      let(:content_type) { "image/png" }

      it_behaves_like "valid image type"
    end

    context "with an ICO" do
      let(:filename) { "icon.ico" }
      let(:content_type) { "image/vnd.microsoft.icon" }

      it_behaves_like "valid image type"

      context "without an extension" do
        let(:blob_filename) { "icon_ico" }

        it_behaves_like "valid image type"
      end
    end
  end

  context "when the file is an Rack::Test::UploadedFile" do
    let(:upload) { Decidim::Dev.test_file(filename, content_type) }

    it_behaves_like "working image dimensions validator", :test_file
  end

  context "when the file is an ActionDispatch::Http::UploadedFile" do
    let(:upload) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: File.open(Decidim::Dev.asset(filename)),
        type: content_type,
        filename:
      )
    end

    it_behaves_like "working image dimensions validator", :uploaded_file
  end

  context "when the file is an ActiveRecord::Attached" do
    subject { record }

    let(:record) { validatable.new(upload: blob) }
    let(:blob_filename) { filename }
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
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset(filename)),
        filename: blob_filename,
        content_type:
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

    it_behaves_like "working image dimensions validator", :test_file
  end

  describe "#validate_image_size" do
    subject { validator.validate_image_size(record, :upload, upload, uploader) }

    let(:validator) { described_class.new(attributes: [:upload], allow: %w(image/jpeg)) }
    let(:record) { validatable.new(upload:) }
    let(:upload) { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    let(:uploader) { record.attached_uploader(:upload) }

    context "when MiniMagick fails to process the image" do
      let(:image) do
        MiniMagick::Image.new(upload.path, File.extname(upload.original_filename))
      end

      before do
        allow(MiniMagick::Image).to receive(:new).and_return(image)
        allow(image).to receive(:dimensions).and_raise(
          MiniMagick::Error.new(
            <<~ERR.strip
              identify-im6.q16: unable to open image `%w': No such file or directory @ error/blob.c/OpenBlob/2924.
              identify-im6.q16: no decode delegate for this image format `' @ error/constitute.c/ReadImage/575.
              identify-im6.q16: unable to open image `%h': No such file or directory @ error/blob.c/OpenBlob/2924.
              identify-im6.q16: unable to open image `%h': No such file or directory @ error/blob.c/OpenBlob/2924.
              identify-im6.q16: no decode delegate for this image format `' @ error/constitute.c/ReadImage/575.
              identify-im6.q16: unable to open image `%b': No such file or directory @ error/blob.c/OpenBlob/2924.
              identify-im6.q16: unable to open image `%b': No such file or directory @ error/blob.c/OpenBlob/2924.
              identify-im6.q16: no decode delegate for this image format `' @ error/constitute.c/ReadImage/575.
              identify-im6.q16: width or height exceeds limit `avatar.jpg' @ error/cache.c/OpenPixelCache/3909.
            ERR
          )
        )
      end

      it "adds the correct error" do
        expect { subject }.not_to raise_error
        expect(record.errors[:upload]).to contain_exactly("File cannot be processed")
      end
    end
  end
end
