# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentBlock do
    subject { content_block }

    let(:content_block) { create(:content_block, manifest_name: :hero, scope_name: :homepage) }

    describe ".manifest" do
      it "finds the correct manifest" do
        expect(subject.manifest.name.to_s).to eq content_block.manifest_name
      end
    end

    describe ".images_container" do
      before do
        # Enable processing for the test in order to catch validation errors
        Decidim::HomepageImageUploader.enable_processing = true
      end

      after do
        Decidim::HomepageImageUploader.enable_processing = false
        content_block.images_container.background_image.remove! if content_block.images_container.background_image
      end

      it "responds to the image names" do
        expect(subject.images_container).to respond_to(:background_image)
      end

      context "when the image has not been uploaded" do
        it "returns nil" do
          expect(subject.images_container.background_image.url).to be_nil
        end
      end

      context "when the related attachment exists" do
        let(:original_image) do
          Rack::Test::UploadedFile.new(
            Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
            "image/jpeg"
          )
        end

        before do
          subject.images_container.background_image = original_image
          subject.save
        end

        it "returns the image" do
          expect(subject.images_container.background_image).not_to be_nil
        end
      end

      context "when the image is larger in size than the organization allows" do
        let(:original_image) do
          Rack::Test::UploadedFile.new(
            Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
            "image/jpeg"
          )
        end

        before do
          content_block.organization.settings.tap do |settings|
            settings.upload.maximum_file_size.default = 1.kilobyte.to_f / 1.megabyte
          end
        end

        it "returns fails to save the image with validation errors" do
          subject.images_container.background_image = original_image
          subject.save
          expect(subject.valid?).to be(false)
          expect(subject.errors[:images_container]).to eq(["is invalid"])
          expect(subject.images_container.errors.full_messages).to eq(
            ["Background image The image is too big"]
          )
          expect(subject.images).to eq({ "background_image" => nil })
        end
      end
    end
  end
end
