# frozen_string_literal: true

require "spec_helper"
require "decidim/page_finder"

module Decidim
  describe PageFinder do
    let(:page_id) { "welcome" }
    let(:organization) { create(:organization) }
    let(:finder) { described_class.new(page_id, organization) }

    describe "page" do
      subject { finder.page }

      context "when a page exists" do
        let!(:page) { create(:static_page, organization: organization, slug: page_id) }

        it { is_expected.to eq(page) }
      end

      context "when otherwise" do
        it { is_expected.to eq(nil) }
      end
    end

    describe "find" do
      subject { finder.find }

      context "when a page exists for the slug" do
        before do
          create(:static_page, organization: organization, slug: page_id)
        end

        it { is_expected.to eq("pages/decidim_page") }
      end

      context "when a page exists for the slug in another organization" do
        before do
          create(:static_page, slug: page_id)
        end

        it { is_expected.to eq("pages/welcome") }
      end

      context "when a template exists" do
        let(:page_id) { "404" }

        it { is_expected.to eq("pages/404") }
      end

      context "when trying to render the decidim_page template" do
        let(:page_id) { "decidim_page" }

        it { expect { subject }.to raise_error(HighVoltage::InvalidPageIdError) }
      end
    end
  end
end
