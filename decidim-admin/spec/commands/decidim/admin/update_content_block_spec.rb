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
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "city.jpeg",
        content_type: "image/jpeg"
      )
    end
    let(:images) do
      {
        "remove_background_image" => "0",
        "background_image" => uploaded_image
      }.with_indifferent_access
    end

    let(:form_klass) { Decidim::Admin::ContentBlockForm }
    let(:form_params) do
      {
        content_block: {
          settings:,
          images:
        }
      }
    end
    let(:form) do
      form_klass.from_params(form_params)
    end

    context "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is valid" do
      it "updates the content block settings" do
        subject.call
        content_block.reload
        expect(content_block.settings.welcome_text["en"]).to eq("My text")
      end

      context "when the image does not exist" do
        it "creates the related image" do
          expect(content_block.images_container.background_image.attached?).to be false

          subject.call
          content_block.reload

          expect(content_block.images_container.background_image.attached?).to be true
          expect(content_block.images_container.attached_uploader(:background_image).path).to be_present
        end
      end

      context "when the image exists" do
        let(:original_image) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Decidim::Dev.asset("city.jpeg")),
            filename: "city.jpeg",
            content_type: "image/jpeg"
          )
        end

        before do
          content_block.images_container.background_image = original_image
          content_block.save
        end

        after do
          content_block.images_container.background_image.purge if content_block.images_container.background_image.attached?
        end

        it "updates the image" do
          expect do
            subject.call
            content_block.reload
          end.to(change { content_block.images_container.attached_uploader(:background_image).path })
        end

        context "with the image being larger in size than the organization allows" do
          before do
            content_block.images_container.background_image.purge
            content_block.organization.settings.tap do |settings|
              settings.upload.maximum_file_size.default = 1.kilobyte.to_f / 1.megabyte
            end
          end

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
            content_block.reload
            expect(content_block.images_container.background_image.attached?).to be false
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
            end.to change { content_block.images_container.background_image.attached? }.to(false)
          end
        end
      end
    end
  end
end
