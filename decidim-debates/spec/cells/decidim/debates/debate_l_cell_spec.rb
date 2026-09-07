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
        expect(subject).to have_text(translated_attribute(debate.title))
        expect(subject).to have_css(".card__list-title")
      end

      it "renders the description" do
        expect(subject).to have_text(decidim_sanitize(translated_attribute(debate.description), strip_tags: true))
        expect(subject).to have_css(".card__list-text")
      end

      context "when the description has a link" do
        let!(:debate) { create(:debate, description:, component:, created_at:) }
        let(:description) { { en: "This is a description with a link to <a href='http://example.org'>example.org</a>" } }

        it "renders the description" do
          expect(subject).to have_text("This is a description with a link to example.org")
        end
      end

      context "when the description has a user mention" do
        let(:mentioned_user) { create(:user, :confirmed, organization: component.participatory_space.organization) }
        let(:raw_description) { "This mentions @#{mentioned_user.nickname} in the debate" }
        let(:parsed_description) do
          parsed = Decidim::ContentProcessor.parse(raw_description, current_organization: component.participatory_space.organization)
          { en: parsed.rewrite }
        end
        let!(:debate) { create(:debate, description: parsed_description, component:, created_at:) }

        it "renders the mention as plain text without a link" do
          expect(subject).to have_text("@#{mentioned_user.nickname}")
          expect(subject).to have_no_text("gid://")
          expect(subject).to have_no_css(".card__list-text a")
        end
      end

      context "when the description has multiple user mentions" do
        let(:mentioned_user1) { create(:user, :confirmed, organization: component.participatory_space.organization) }
        let(:mentioned_user2) { create(:user, :confirmed, organization: component.participatory_space.organization) }
        let(:raw_description) { "Debate between @#{mentioned_user1.nickname} and @#{mentioned_user2.nickname}" }
        let(:parsed_description) do
          parsed = Decidim::ContentProcessor.parse(raw_description, current_organization: component.participatory_space.organization)
          { en: parsed.rewrite }
        end
        let!(:debate) { create(:debate, description: parsed_description, component:, created_at:) }

        it "renders all mentions as plain text without links" do
          expect(subject).to have_text("@#{mentioned_user1.nickname}")
          expect(subject).to have_text("@#{mentioned_user2.nickname}")
          expect(subject).to have_no_text("gid://")
          expect(subject).to have_no_css(".card__list-text a")
        end
      end
    end
  end
end
