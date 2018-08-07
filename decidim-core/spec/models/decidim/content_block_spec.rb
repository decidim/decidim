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

    describe ".images" do
      context "when the related attachment does not exist" do
        it "returns nil" do
          expect(subject.images.hero_background_image).to be_nil
        end
      end

      context "when the related attachment exists" do
        before do
          create(:attachment, attached_to: subject, title: { name: :hero_background_image })
        end

        it "returns nil" do
          expect(subject.images.hero_background_image).to be_kind_of(Decidim::Attachment)
          expect(subject.attachments.count).to eq 1
        end
      end
    end
  end
end
