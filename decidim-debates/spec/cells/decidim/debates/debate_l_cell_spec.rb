# frozen_string_literal: true

require "spec_helper"

module Decidim::Debates
  describe DebateLCell, type: :cell do
    controller Decidim::Debates::DebatesController

    subject { cell_html }

    let(:my_cell) { cell("decidim/debates/debate_l", debate, context: { show_space: }) }
    let(:cell_html) { my_cell.call }
    let(:created_at) { 1.month.ago }
    let(:component) { create(:debates_component) }
    let!(:debate) { create(:debate, component:, created_at:) }
    let(:model) { debate }
    let(:user) { create(:user, organization: debate.participatory_space.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it_behaves_like "m-cell", :debate

      it "renders the card" do
        expect(subject).to have_css("[id^='debates__debate']")
      end

      it "renders the comments count" do
        expect(subject).to have_css(".card__list-metadata [data-comments-count]")
      end

      it "renders the title" do
        expect(subject).to have_content(translated_attribute(debate.title))
        expect(subject).to have_css(".card__list-title")
      end

      it "renders the description" do
        expect(subject).to have_content(decidim_sanitize(translated_attribute(debate.description), strip_tags: true))
        expect(subject).to have_css(".card__list-text")
      end

      context "when the description has a link" do
        let!(:debate) { create(:debate, description:, component:, created_at:) }
        let(:description) { { en: "This is a description with a link to <a href='http://example.org'>example.org</a>" } }

        it "renders the description" do
          expect(subject).to have_content("This is a description with a link to example.org")
        end
      end
    end
  end
end
