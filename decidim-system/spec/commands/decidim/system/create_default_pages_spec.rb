# frozen_string_literal: true
require "spec_helper"

module Decidim
  module System
    describe CreateDefaultPages do
      let(:organization) { create(:organization) }
      subject { described_class.new(organization).call }

      it "creates all the default pages for an organization" do
        expect do
          subject
        end.to change { organization.static_pages.count }.by(Decidim::StaticPage::DEFAULT_PAGES.length)
      end

      it "sets the content with each locale" do
        I18n.available_locales = [:en, :ca]

        subject

        organization.static_pages.each do |page|
          expect(page.title["en"]).to be
          expect(page.title["ca"]).to be
          expect(page.content["en"]).to be
          expect(page.content["ca"]).to be
        end
      end
    end
  end
end
