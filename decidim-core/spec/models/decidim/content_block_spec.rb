# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentBlock do
    subject { content_block }

    let(:content_block) { create(:content_block, manifest_name: :hero, scope: :homepage) }

    describe ".manifest" do
      it "finds the correct manifest" do
        expect(subject.manifest.name.to_s).to eq content_block.manifest_name
      end
    end

    describe ".images_container" do
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
            "image/jpg"
          )
        end

        before do
          subject.images_container.background_image = original_image
          subject.save
        end

        it "returns nil" do
          expect(subject.images_container.background_image).not_to be_nil
        end
      end
    end
  end
end
