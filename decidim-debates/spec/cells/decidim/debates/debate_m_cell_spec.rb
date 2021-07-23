# frozen_string_literal: true

require "spec_helper"

module Decidim::Debates
  describe DebateMCell, type: :cell do
    controller Decidim::Debates::DebatesController

    subject { cell_html }

    let(:component) { create(:debates_component) }
    let!(:debate) { create(:debate, component: component) }
    let(:model) { debate }
    let(:cell_html) { cell("decidim/debates/debate_m", debate, context: { show_space: show_space }).call }

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card--debate")
      end

      context "when comments are blocked" do
        let(:component) { create(:debates_component, :with_comments_disabled) }

        it "doesn't renders comments" do
          expect(subject).not_to have_css(".comments-icon")
        end
      end
    end
  end
end
