# frozen_string_literal: true

require "spec_helper"

describe PassthruValidator do
  subject { validatable.new(file:, organization:) }

  let(:validator_settings) { {} }

  let(:uploader) do
    Class.new(Decidim::ApplicationUploader) do
      def content_type_allowlist
        %w(image/jpeg image/png)
      end
    end
  end

  let(:to_class) do
    mount_class = uploader
    Class.new(ApplicationRecord) do
      include Decidim::HasUploadValidations

      self.table_name = "decidim_dummy_resources_dummy_resources"

      def self.model_name
        ActiveModel::Name.new(self, nil, "Passthrough")
      end

      attr_accessor :organization, :file

      validates_upload(:file, uploader: mount_class)
    end
  end

  let(:validatable) do
    validator_config = validator_settings.merge(passthru: { to: to_class })
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      include Decidim::AttributeObject::Model
      include ActiveModel::Validations

      attribute :file
      attribute :organization

      validates :file, validator_config
    end
  end

  let(:organization) { create(:organization) }

  context "when the file is valid" do
    let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

    it { is_expected.to be_valid }
  end

  context "when the file is not valid" do
    context "with incorrect content type" do
      let(:file) { Decidim::Dev.test_file("city.jpeg", "application/pdf") }

      it "adds the passthrough record's validation errors on the field" do
        expect(subject).to be_invalid
        expect(subject.errors[:file]).to eq(
          ["file should be one of image/jpeg, image/png"]
        )
      end
    end

    context "with too large file size" do
      let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

      before do
        subject.organization.settings.tap do |settings|
          # The city.jpeg is about 100kb
          settings.upload.maximum_file_size.default = 1.kilobyte.to_f / 1.megabyte
        end
      end

      it "adds the passthrough record's validation errors on the field" do
        expect(subject).to be_invalid
        expect(subject.errors[:file]).to eq(
          ["file size must be less than or equal to 1 KB"]
        )
      end
    end

    context "with conditions" do
      let(:file) { Decidim::Dev.test_file("city.jpeg", "application/pdf") }

      context "when the if condition returns true" do
        let(:validator_settings) { { if: -> { true } } }

        it { is_expected.to be_invalid }
      end

      context "when the if condition returns false" do
        let(:validator_settings) { { if: -> { false } } }

        it { is_expected.to be_valid }
      end

      context "when the unless condition returns true" do
        let(:validator_settings) { { unless: -> { true } } }

        it { is_expected.to be_valid }
      end

      context "when the unless condition returns false" do
        let(:validator_settings) { { unless: -> { false } } }

        it { is_expected.to be_invalid }
      end
    end
  end
end
