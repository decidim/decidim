# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe CreateDefaultPages do
      subject { described_class.new(organization1) }

      let(:organization1) { create(:organization) }
      let(:organization2) { create(:organization) }

      before do
        described_class.new(organization1).call
        described_class.new(organization2).call
      end

      it "creates all the default pages for an organization alt" do
        expect(organization1.static_pages.count).to eq(Decidim::StaticPage::DEFAULT_PAGES.length)
        expect(organization2.static_pages.count).to eq(Decidim::StaticPage::DEFAULT_PAGES.length)
      end

      it "sets the content with each locale" do
        allow(Decidim).to receive(:available_locales).and_return [:en, :ca]

        described_class.new(organization1).call

        organization1.static_pages.each do |page|
          expect(page.title["en"]).not_to be_nil
          expect(page.title["ca"]).not_to be_nil
          expect(page.content["en"]).not_to be_nil
          expect(page.content["ca"]).not_to be_nil
        end
      end
    end
  end
end
