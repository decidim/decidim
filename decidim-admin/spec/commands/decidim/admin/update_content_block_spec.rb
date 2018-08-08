# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateContentBlock do
    subject { described_class.new(form, content_block, scope) }

    let(:content_block) { create :content_block, manifest_name: :hero, scope: scope }
    let(:scope) { :homepage }
    let(:settings) do
      {
        welcome_text_en: "My text"
      }
    end
    let(:file) do
      Rack::Test::UploadedFile.new(
        Decidim::Dev.test_file("city2.jpeg", "image/jpeg"),
        "image/jpg"
      )
    end
    let(:images) do
      {
        "hero_background_image" => file
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
        it "creates the related attachment" do
          expect(content_block.attachments).to eq []

          subject.call
          content_block.reload

          expect(content_block.attachments.count).to eq 1
          expect(content_block.attachments.first.title).to eq("name" => "hero_background_image")
        end
      end

      context "when the image exists" do
        let!(:attachment) do
          create :attachment, attached_to: content_block, title: { name: :hero_background_image }
        end

        it "updates the image" do
          expect do
            subject.call
            attachment.reload
          end.to change(attachment, :updated_at)
        end

        context "when removing the image" do
          let(:images) do
            {
              "remove_hero_background_image" => "1",
              "hero_background_image" => file
            }.with_indifferent_access
          end

          it "deletes the attachment" do
            expect do
              subject.call
              content_block.reload
            end.to change { content_block.attachments.count }.from(1).to(0)
          end
        end
      end
    end
  end
end
