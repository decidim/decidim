# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FileValidatorHumanizer do
    subject { FileValidatorHumanizer.new(validatable.new, :file) }

    let(:uploader) do
      Class.new(Decidim::ApplicationUploader) do
        def extension_whitelist
          %w(jpeg jpg png)
        end
      end
    end

    let(:validatable) do
      mount_class = uploader
      Class.new do
        extend CarrierWave::Mount
        include ActiveModel::Model
        include Decidim::HasUploadValidations

        def self.model_name
          ActiveModel::Name.new(self, nil, "Validatable")
        end

        attr_accessor :file
        validates_upload :file
        mount_uploader :file, mount_class

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
    end

    describe "#extension_whitelist" do
      it "returns the correct extensions" do
        expect(subject.extension_whitelist).to eq(%w(jpeg jpg png))
      end
    end
  end
end
