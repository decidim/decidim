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
        filename:,
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
end
