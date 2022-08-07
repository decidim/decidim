# frozen_string_literal: true

require "spec_helper"

# This validator is primarily used to validate the records during upload using
# the passthru validator. Therefore, we will not create an actual record to be
# validated but we call the validator manually in order to use it similarly as
# the passthru validator uses it for the upload form objects.
describe UploaderContentTypeValidator do
  subject do
    dummy_record = validatable.new(organization:)
    dummy_record.class.validators_on(:file).each do |validator|
      validator.validate_each(dummy_record, :file, file)
    end
    dummy_record.errors
  end

  let(:uploader) do
    Class.new(Decidim::ApplicationUploader) do
      def content_type_allowlist
        %w(image/jpeg image/png)
      end
    end
  end

  let(:file_validation_options) { {} }

  let(:validatable) do
    mount_class = uploader
    validation_options = file_validation_options
    Class.new(ApplicationRecord) do
      include Decidim::HasUploadValidations

      self.table_name = "decidim_dummy_resources_dummy_resources"

      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      attr_accessor :file
      attr_accessor :organization

      validates_upload(:file, **validation_options.merge(uploader: mount_class))
    end
  end

  let(:organization) { create(:organization) }

  context "when the file is valid" do
    let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

    it { is_expected.to be_empty }
  end

  context "when the file is not valid" do
    let(:file) { Decidim::Dev.test_file("city.jpeg", "application/pdf") }

    it "adds the content type error" do
      expect(subject.count).to eq(1)
      expect(subject[:file]).to eq(
        ["file should be one of *.jpeg, *.jpg, *.png"]
      )
    end

    context "and the content type contains a recognized wildcard match" do
      let(:uploader) do
        Class.new(Decidim::ApplicationUploader) do
          def content_type_allowlist
            %w(image/*)
          end
        end
      end

      it "adds the correct content type error with the allowed extensions" do
        expect(subject.count).to eq(1)
        expect(subject[:file]).to eq(
          ["file should be one of *.bmp, *.gif, *.jpeg, *.jpg, *.png"]
        )
      end
    end

    context "and the content type contains an unrecognized wildcard match" do
      let(:uploader) do
        Class.new(Decidim::ApplicationUploader) do
          def content_type_allowlist
            %w(foobar/*)
          end
        end
      end

      it "adds the content type to the error" do
        expect(subject.count).to eq(1)
        expect(subject[:file]).to eq(
          ["file should be one of foobar/*"]
        )
      end
    end

    context "and the content type contains a recognized and an unrecognized wildcard match" do
      let(:uploader) do
        Class.new(Decidim::ApplicationUploader) do
          def content_type_allowlist
            %w(image/* foobar/*)
          end
        end
      end

      it "adds the recognized extensions and content type to the error in correct order" do
        expect(subject.count).to eq(1)
        expect(subject[:file]).to eq(
          ["file should be one of *.bmp, *.gif, *.jpeg, *.jpg, *.png, foobar/*"]
        )
      end
    end

    context "and the uploader defines forbidden types" do
      let(:uploader) do
        Class.new(Decidim::ApplicationUploader) do
          def content_type_denylist
            %w(image/jpeg)
          end
        end
      end
      let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

      it "adds the possible file extensions to the error message" do
        expect(subject.count).to eq(1)
        expect(subject[:file]).to eq(
          ["file cannot be *.jpe, *.jpeg, *.jpg"]
        )
      end
    end
  end
end
