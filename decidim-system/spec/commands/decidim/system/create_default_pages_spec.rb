# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe CreateDefaultPages do
      subject { described_class.new(organization1) }

      let!(:organization1) { create(:organization, create_static_pages: false) }
      let!(:organization2) { create(:organization, create_static_pages: false) }

      before do
        expect(Decidim::StaticPage.count).to eq 0
      end

      it "creates all the default pages for an organization alt" do
        described_class.new(organization1).call
        described_class.new(organization2).call

        expect(organization1.static_pages.count).to eq(Decidim::StaticPage::DEFAULT_PAGES.length)
        expect(organization2.static_pages.count).to eq(Decidim::StaticPage::DEFAULT_PAGES.length)
      end

      it "sets the content with each locale" do
        allow(Decidim).to receive(:available_locales).and_return [:en, :ca]

        described_class.new(organization1).call

        organization1.static_pages.each do |page|
          expect(page.title["en"]).not_to be_nil
          expect(page.title["ca"]).not_to be_nil
          unless page.slug == "terms-of-service"
            expect(page.content["en"]).not_to be_nil
            expect(page.content["ca"]).not_to be_nil
          end
        end
      end

      it "sets the content with translatable title" do
        described_class.new(organization1).call

        organization1.static_pages.each do |page|
          expect(page.title["en"]).to include(I18n.t(page.slug, scope: "decidim.system.default_pages"))
        end
      end

      it "sets the terms-of-service page as allowed for public access" do
        described_class.new(organization1).call

        expect(
          organization1.static_pages.find_by(
            slug: "terms-of-service"
          ).allow_public_access
        ).to be(true)
      end

      it "creates the terms-of-service summary content block" do
        expect do
          described_class.new(organization1).call
        end.to change { Decidim::ContentBlock.where(organization: organization1, scope_name: :static_page).where.not(published_at: nil).count }.by 1
      end
    end
  end
end
