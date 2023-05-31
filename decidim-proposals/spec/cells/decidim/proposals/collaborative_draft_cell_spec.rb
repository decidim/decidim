# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::CollaborativeDraftCell, type: :cell do
  controller Decidim::Proposals::CollaborativeDraftsController

  subject { my_cell.call(:show) }

  let(:my_cell) { cell("decidim/proposals/collaborative_draft", collaborative_draft, context:) }

  let(:component) { create(:proposal_component, :with_collaborative_drafts_enabled) }
  let(:author) { create(:user, :confirmed, organization: component.organization) }
  let!(:collaborative_draft) { create(:collaborative_draft, component:) }
  let(:authors) { create_list(:user, 5, organization: component.organization) }
  let(:collaborative_draft_va) { create(:collaborative_draft, component:, users: authors) }
  let(:context) { nil }

  let(:card_label) { subject.find(".card__label") }
  let(:card_content) { subject.find(".card__content") }
  let(:card_footer) { subject.find(".card__footer") }
  let(:card_text) { subject.find(".card__text") }

  before do
    allow(controller).to receive(:current_user).and_return(author)
  end

  context "when rendering a collaborative_draft" do
    it "renders the card" do
      expect(subject).to have_css(".card--collaborative_draft")
    end

    describe "with the label option" do
      let(:context) { { label: true } }

      it "renders the collaborative_draft label" do
        expect(subject).to have_css(".card__label")
        expect(card_label).to have_content("Collaborative draft")
      end
    end

    it "renders the collaborative_draft title and link" do
      expect(card_content).to have_content(collaborative_draft.title)
      href = Decidim::ResourceLocatorPresenter.new(collaborative_draft).path
      expect(card_content).to have_link(class: "card__link", href:)
    end

    it "renders the footer link" do
      expect(card_footer).to have_content("View Collaborative Draft")
      href = Decidim::ResourceLocatorPresenter.new(collaborative_draft).path
      expect(card_footer).to have_link(class: "card__button", href:)
    end

    it "renders the card author" do
      expect(card_content).to have_content(collaborative_draft.authors.first.name)
      expect(card_content).to have_css(".author__name", count: 1)
    end

    # collapsible lists uses javascript which is not available when testing cells without a real browser
    describe "with coauthors" do
      let(:collaborative_draft) { create(:collaborative_draft, component:, users: authors) }

      it "renders the first three authors" do
        expect(card_content).to have_css(".author__name", count: 5)
      end

      it "indicates number of hidden authors" do
        expect(card_content).to have_css(".card__text--paragraph.collapsible-list__see-more")
        expect(card_content.find(".card__text--paragraph.collapsible-list__see-more")).to have_content("and 4 more")
      end

      it "renders the see_more link" do
        expect(card_content).to have_css(".collapsible-list__see-more")
      end

      it "renders the see_less link" do
        expect(card_content).to have_css(".collapsible-list__see-less")
      end
    end

    context "with open state" do
      let(:collaborative_draft) { create(:collaborative_draft, :open, component:) }

      it "renders the card with the .success class" do
        expect(subject).to have_css(".card.success")
      end

      it "renders the open state" do
        expect(card_text).to have_css(".success.card__text--status")
        expect(card_text).to have_content("Open")
      end
    end

    context "with withdrawn state" do
      let(:collaborative_draft) { create(:collaborative_draft, :withdrawn, component:) }

      it "renders the card with the .alert class" do
        expect(subject).to have_css(".card.alert")
      end

      it "renders the open state" do
        expect(card_text).to have_css(".alert.card__text--status")
        expect(card_text).to have_content("Withdrawn")
      end
    end

    context "with published state" do
      let(:collaborative_draft) { create(:collaborative_draft, :published, component:) }

      it "renders the card with the .secondary class" do
        expect(subject).to have_css(".card.secondary")
      end

      it "renders the open state" do
        expect(card_text).to have_css(".secondary.card__text--status")
        expect(card_text).to have_content("Published")
      end
    end
  end
end
