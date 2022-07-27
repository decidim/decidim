# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentParsers::InlineImagesParser do
    subject { parser }

    let(:base64_content) { File.open(Decidim::Dev.asset("base64_content.html")) }
    let(:html_without_images) { "<p>This is an awesome paragraph</p><p>Tiene acentos, cómo no</p>" }
    let(:user) { create(:user, :confirmed, :admin) }
    let(:context) { { user: } }
    let(:parser) { described_class.new(content, context) }

    describe "inline_images?" do
      context "when content includes inline images" do
        let(:content) { base64_content }

        it { expect(subject).to be_inline_images }
      end

      context "when content doesn't include inline images" do
        let(:content) { html_without_images }

        it { expect(subject).not_to be_inline_images }
      end
    end

    describe "rewrite" do
      context "when content includes inline images" do
        let(:content) { base64_content }

        it "converts the image to an ActiveStorage attachment" do
          result = subject.rewrite
          expect(result).not_to eq(content)
          editor_image = Decidim::EditorImage.last
          expect(result).to include("img src=\"#{editor_image.attached_uploader(:file).path}\"")
        end

        it "creates a Decidim::EditorImage instance" do
          expect { subject.rewrite }.to change(Decidim::EditorImage, :count).by(1)
        end
      end

      context "when content doesn't include inline images" do
        let(:content) { html_without_images }

        it "doesn't change the content" do
          expect(subject.rewrite).to eq(html_without_images)
        end
      end
    end
  end
end
