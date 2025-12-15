# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    describe CreateDemocraticQualityIndicatorsPage do
      subject { described_class.new(organization1.id) }
      let!(:organization1) { create(:organization, create_static_pages: false) }
      let!(:organization2) { create(:organization, create_static_pages: false) }

      before do
        expect(Decidim::StaticPage.count).to eq 0
      end

      it "creates the indicators page for all the organizations" do
        described_class.new(organization1.id).call
        described_class.new(organization2.id).call

        expect(organization1.static_pages.count).to eq(1)
        expect(organization2.static_pages.count).to eq(1)
      end

      it "sets the content with translatable title" do
        described_class.new(organization1.id).call

        organization1.static_pages.each do |page|
          expect(page.title["en"]).to include(I18n.t("title", scope: "decidim.participatory_processes.static_pages.democratic_quality_indicators"))
        end
      end

      it "sets the content with each locale" do
        allow(Decidim).to receive(:available_locales).and_return [:en, :ca]

        described_class.new(organization1.id).call
        organization1.static_pages.each do |page|
          expect(page.title["en"]).not_to be_nil
          expect(page.title["ca"]).not_to be_nil
          expect(page.slug).to eq("democratic-quality-indicators")
          expect(page.allow_public_access).to be_truthy
        end
      end
    end
  end
end
