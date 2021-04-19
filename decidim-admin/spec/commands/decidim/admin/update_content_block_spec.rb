# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateContentBlock do
    subject { described_class.new(form, content_block, scope) }

    let(:content_block) { create :content_block, manifest_name: :hero, scope_name: scope }
    let(:scope) { :homepage }
    let(:settings) do
      {
        welcome_text_en: "My text"
      }
    end
    let(:uploaded_image) do
      Rack::Test::UploadedFile.new(
        Decidim::Dev.test_file("city2.jpeg", "image/jpeg"),
        "image/jpeg"
      )
    end
    let(:images) do
      {
        "remove_background_image" => "0",
        "background_image" => uploaded_image
      }.with_indifferent_access
    end

    let(:form) do
      double(
        invalid?: invalid,
        settings: settings,
        images: images
      )
    end
    let(:invalid) { false }

    before do
      Decidim::AttachmentUploader.enable_processing = true
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is valid" do
      it "updates the content block settings" do
        subject.call
        content_block.reload
        expect(content_block.settings.welcome_text[:en]).to eq("My text")
      end

      context "when the image does not exist" do
        it "creates the related image" do
          expect(content_block.images).to eq({ "background_image" => nil })

          subject.call
          content_block.reload

          expect(content_block.images).not_to be_empty
          expect(content_block.images_container.background_image.url).to be_present
        end
      end

      context "when the image exists" do
        let(:original_image) do
          Rack::Test::UploadedFile.new(
            Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
            "image/jpeg"
          )
        end

        before do
          # Enable processing for the test in order to catch validation errors
          Decidim::HomepageImageUploader.enable_processing = true

          content_block.images_container.background_image = original_image
          content_block.save
        end

        after do
          Decidim::HomepageImageUploader.enable_processing = false
          content_block.images_container.background_image.remove! if content_block.images_container.background_image
        end

        it "updates the image" do
          expect do
            subject.call
            content_block.reload
          end.to(change { content_block.images_container.background_image.url })
        end

        context "with the image being larger in size than the organization allows" do
          before do
            content_block.organization.settings.tap do |settings|
              settings.upload.maximum_file_size.default = 1.kilobyte.to_f / 1.megabyte
            end
          end

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when removing the image" do
          let(:images) do
            {
              "remove_background_image" => "1"
            }.with_indifferent_access
          end

          it "deletes the attachment" do
            expect do
              subject.call
              content_block.reload
            end.to change { content_block.images.values }.to([nil])
          end
        end
      end
    end
  end
end
