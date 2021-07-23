# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FileValidatorHumanizer do
    subject { FileValidatorHumanizer.new(validatable.new, :file) }

    let(:uploader) do
      Class.new(Decidim::ApplicationUploader) do
        def extension_allowlist
          %w(jpeg jpg png)
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

        validates_upload(:file, **validation_options.merge(uploader: mount_class))

        def organization
          @organization ||= FactoryBot.create(:organization)
        end
      end
    end

    describe "#uploader" do
      it "returns the correct uploader" do
        expect(subject.uploader).to be_a(uploader)
      end
    end

    describe "#messages" do
      it "returns the correct messages" do
        expect(subject.messages).to eq(
          [
            "Maximum file size: 10MB",
            "Allowed file extensions: jpeg jpg png"
          ]
        )
      end
    end

    describe "#max_file_size" do
      it "returns the correct max file size" do
        expect(subject.max_file_size).to eq(10.megabytes)
      end

      context "when the file validator conditions are set as static numbers" do
        let(:file_validation_options) { { max_size: 1.megabyte } }

        it "returns the correct max file size" do
          expect(subject.max_file_size).to eq(1.megabyte)
        end
      end
    end

    describe "#extension_allowlist" do
      it "returns the correct extensions" do
        expect(subject.extension_allowlist).to eq(%w(jpeg jpg png))
      end
    end
  end
end
