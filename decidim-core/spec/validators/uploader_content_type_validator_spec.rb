# frozen_string_literal: true

require "spec_helper"

# This validator is primarily used to validate the records during upload using
# the passthru validator. Therefore, we will not create an actual record to be
# validated but we call the validator manually in order to use it similarly as
# the passthru validator uses it for the upload form objects.
describe UploaderContentTypeValidator do
  subject do
    dummy_record = validatable.new(organization: organization)
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
    let(:file) { Rack::Test::UploadedFile.new(Decidim::Dev.test_file("city.jpeg", "application/pdf")) }

    it "adds the content type error" do
      expect(subject.count).to eq(1)
      expect(subject[:file]).to eq(
        ["file should be one of image/jpeg, image/png"]
      )
    end
  end
end
