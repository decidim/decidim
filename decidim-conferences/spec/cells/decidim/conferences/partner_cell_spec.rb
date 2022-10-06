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
        expect(subject).to have_css(".partner-box")
      end
    end

    context "when rendering a collaborator" do
      let(:partner) { create(:partner, :collaborator, conference:) }

      it "renders a User_group author card" do
        expect(subject).to have_css(".partner-box")
      end
    end
  end
end
