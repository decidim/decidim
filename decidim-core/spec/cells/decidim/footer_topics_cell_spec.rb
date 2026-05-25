# frozen_string_literal: true

require "spec_helper"

describe Decidim::FooterTopicsCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/footer_topics", nil) }
  let(:organization) { create(:organization) }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  context "when there is not any topic" do
    it "returns an empty cell" do
      expect(subject.text).to be_blank
    end
  end

  context "when there are topics" do
    let(:topic) { create(:static_page_topic, organization:) }
    let!(:page) { create(:static_page, organization:, topic:) }

    it "returns the list of topics" do
      expect(subject).to have_css("nav[aria-label='#{I18n.t("layouts.decidim.footer.help")}']")
      expect(subject).to have_link(href: "/#{I18n.locale}/pages/#{page.slug}")
    end

    context "when the locale is different" do
      let(:locale) { "ca" }

      around do |example|
        I18n.with_locale(locale) { example.run }
      end

      it "returns the list of topics" do
        expect(subject).to have_css("nav[aria-label='#{I18n.t("layouts.decidim.footer.help")}']")
        expect(subject).to have_link(href: "/#{locale}/pages/#{page.slug}")
      end
    end
  end
end
