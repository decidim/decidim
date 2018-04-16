# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe CreateDefaultPages do
      subject { described_class.new(organization).call }

      let(:organization) { create(:organization) }

      it "creates all the default pages for an organization" do
        expect do
          subject
        end.to change { organization.static_pages.count }.by(Decidim::StaticPage::DEFAULT_PAGES.length)
      end

      it "sets the content with each locale" do
        allow(Decidim).to receive(:available_locales).and_return [:en, :ca]

        subject

        organization.static_pages.each do |page|
          expect(page.title["en"]).not_to be_nil
          expect(page.title["ca"]).not_to be_nil
          expect(page.content["en"]).not_to be_nil
          expect(page.content["ca"]).not_to be_nil
        end
      end
    end
  end
end
