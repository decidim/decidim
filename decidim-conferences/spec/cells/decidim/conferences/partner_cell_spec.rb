# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe PartnerCell, type: :cell do
    subject { my_cell.call }

    let(:my_cell) { cell("decidim/conferences/partner", partner) }
    let!(:conference) { create(:conference) }
    let(:partner) { create(:partner, :main_promotor, conference:) }

    context "when rendering a main_promotor" do
      it "renders a partner card" do
        expect(subject).to have_css(".conference__grid-item")
      end
    end

    context "when rendering a collaborator" do
      let(:partner) { create(:partner, :collaborator, conference:) }

      it "renders a User author card" do
        expect(subject).to have_css(".conference__grid-item")
      end
    end

    context "when rendering a partner with a link" do
      it "renders a link" do
        expect(subject).to have_css("a.conference__grid-item")
      end
    end

    context "when rendering a partner without a link" do
      let(:partner) { create(:partner, :collaborator, conference:, link: nil) }

      it "renders a div instead of a link" do
        expect(subject).to have_css("div.conference__grid-item")
      end
    end
  end
end
