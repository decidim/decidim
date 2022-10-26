# frozen_string_literal: true

require "spec_helper"

describe ActiveModel::Validations::FileContentTypeValidator do
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

    it "does not add any errors" do
      expect(subject.count).to eq(0)
    end
  end

  context "when the file is not valid" do
    let(:file) { Decidim::Dev.test_file("city.jpeg", "application/pdf") }

    it "adds the content type error" do
      expect(subject.count).to eq(1)
      expect(subject[:file]).to eq(
        ["only files with the following extensions are allowed: jpeg, jpg, png"]
      )
    end

    context "and the content type is text/csv" do
      let(:organization) do
        create(
          :organization,
          file_upload_settings: Decidim::OrganizationSettings.default(:upload).deep_merge(
            "allowed_file_extensions" => { "default" => ["csv"] }
          )
        )
      end

      let(:uploader) do
        Class.new(Decidim::ApplicationUploader) do
          def content_type_allowlist
            %w(text/csv)
          end
        end
      end

      it "adds the content type error" do
        expect(subject.count).to eq(1)
        expect(subject[:file]).to eq(
          ["only files with the following extensions are allowed: csv"]
        )
      end
    end
  end
end
