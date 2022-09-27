# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OrganizationSettings do
    subject { described_class.new(organization) }

    let(:organization) { create(:organization) }
    let(:db_settings) { organization.file_upload_settings }
    let(:default_settings) do
      {
        "allowed_file_extensions" => {
          "default" => %w(jpg jpeg png pdf rtf txt),
          "admin" => %w(jpg jpeg png pdf doc docx xls xlsx ppt pptx ppx rtf txt odt ott odf otg ods ots),
          "image" => %w(jpg jpeg png),
          "favicon" => %w(png)
        },
        "allowed_content_types" => {
          "default" => %w(
            image/*
            application/pdf
            application/rtf
            text/plain
          ),
          "admin" => %w(
            image/*
            application/vnd.oasis.opendocument
            application/vnd.ms-*
            application/msword
            application/vnd.ms-word
            application/vnd.openxmlformats-officedocument
            application/vnd.oasis.opendocument
            application/pdf
            application/rtf
            text/plain
          )
        },
        "maximum_file_size" => {
          "default" => 10,
          "avatar" => 5
        }
      }
    end

    describe ".for" do
      subject { described_class.for(organization) }

      it "creates a new settings instance for the given organization" do
        expect(subject).to be_a(described_class)
        expect(struct_to_hash(subject)).to eq(
          "upload" => db_settings
        )
      end

      context "with a new organization" do
        let(:organization) { Decidim::Organization.new }

        it "creates a new settings instance for the given organization" do
          expect(subject).to be_a(described_class)
          expect(struct_to_hash(subject)).to eq(
            "upload" => described_class.default(:upload)
          )
        end
      end
    end

    describe ".reload" do
      subject { described_class.for(organization) }

      let(:updated_settings) do
        {
          "allowed_file_extensions" => {
            "default" => %w(jpg jpeg pdf),
            "admin" => %w(jpg jpeg pdf docx),
            "image" => %w(jpg jpeg),
            "favicon" => %w(png)
          },
          "allowed_content_types" => {
            "default" => %w(
              image/*
              application/pdf
            ),
            "admin" => %w(
              image/*
              application/pdf
              application/vnd.openxmlformats-officedocument
            )
          },
          "maximum_file_size" => {
            "default" => 5,
            "avatar" => 2
          }
        }
      end

      it "reloads the settings when they are changed" do
        # Do not call the subject here yet, just call .for in order to store the
        # initial configurations to the registry.
        initial = described_class.for(organization)
        expect(initial).to be_a(described_class)
        expect(struct_to_hash(initial)).to eq("upload" => db_settings)

        # Update the settings and check that the subject matches with the
        # updated settings after the reload method is called.
        organization.file_upload_settings = updated_settings
        described_class.reload(organization)

        expect(struct_to_hash(subject)).to eq("upload" => updated_settings)
      end

      context "when the organization settings have not yet been loaded" do
        it "loads the settings" do
          described_class.reload(organization)
          expect(struct_to_hash(subject)).to eq("upload" => default_settings)
        end
      end
    end

    describe ".default" do
      it "returns the correct default upload configurations" do
        expect(described_class.default(:upload)).to eq(default_settings)
      end

      it "returns the correct allowed file extensions configs" do
        expect(
          described_class.default(:upload, :allowed_file_extensions)
        ).to eq(default_settings["allowed_file_extensions"])
        expect(
          described_class.default(:upload, :allowed_file_extensions, :default)
        ).to eq(default_settings["allowed_file_extensions"]["default"])
        expect(
          described_class.default(:upload, :allowed_file_extensions, :admin)
        ).to eq(default_settings["allowed_file_extensions"]["admin"])
        expect(
          described_class.default(:upload, :allowed_file_extensions, :image)
        ).to eq(default_settings["allowed_file_extensions"]["image"])
      end
    end

    describe ".defaults" do
      subject { described_class.defaults }

      it "returns a new instance of the class with the default configurations" do
        expect(subject).to be_a(described_class)
        expect(struct_to_hash(subject)).to eq("upload" => default_settings)
      end
    end

    describe "#wrap_upload_maximum_file_size" do
      it "turns the passed value into megabytes" do
        expect(subject.wrap_upload_maximum_file_size(1)).to eq(1.megabytes)
      end
    end

    describe "#wrap_upload_maximum_file_size_avatar" do
      it "turns the passed value into megabytes" do
        expect(subject.wrap_upload_maximum_file_size_avatar(1)).to eq(1.megabytes)
      end
    end

    describe "#wrap_upload_allowed_content_types" do
      it "turns the passed array of strings into array of regular expressions" do
        expect(
          subject.wrap_upload_allowed_content_types(
            %w(
              image/*
              application/pdf
            )
          )
        ).to eq([%r{image/.*?}, %r{application/pdf}])
      end
    end

    describe "#wrap_upload_allowed_content_types_admin" do
      it "turns the passed array of strings into array of regular expressions" do
        expect(
          subject.wrap_upload_allowed_content_types_admin(
            %w(
              image/*
              application/pdf
            )
          )
        ).to eq([%r{image/.*?}, %r{application/pdf}])
      end
    end

    private

    def struct_to_hash(struct)
      struct.to_h.to_h do |key, value|
        value = struct_to_hash(value) if value.is_a?(OpenStruct)
        [key.to_s, value]
      end
    end
  end
end
