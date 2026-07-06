# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pages
    describe Page do
      subject { page }

      let(:page) { create(:page) }

      include_examples "has component"
      include_examples "resourceable"
      include_examples "has reference"

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      context "without a component" do
        let(:page) { build(:page, component: nil) }

        it { is_expected.not_to be_valid }
      end

      context "without a valid component" do
        let(:page) { build(:page, component: build(:component, manifest_name: "proposals")) }

        it { is_expected.not_to be_valid }
      end

      it "has an associated component" do
        expect(page.component).to be_a(Decidim::Component)
      end

      describe "attachments" do
        it "has attachments association" do
          expect(page).to respond_to(:attachments)
          expect(page).to respond_to(:photos)
          expect(page).to respond_to(:documents)
        end

        it "has admin attachment context" do
          expect(page.attachment_context).to eq(:admin)
        end

        context "when page has attachments" do
          let!(:photo) { create(:attachment, :with_image, attached_to: page) }
          let!(:document) { create(:attachment, :with_pdf, attached_to: page) }

          it "returns photos" do
            expect(page.photos).to include(photo)
            expect(page.photos).not_to include(document)
          end

          it "returns documents" do
            expect(page.documents).to include(document)
            expect(page.documents).not_to include(photo)
          end
        end
      end
    end
  end
end
