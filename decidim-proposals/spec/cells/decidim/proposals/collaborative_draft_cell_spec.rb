# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::CollaborativeDraftCell, type: :cell do
  controller Decidim::Proposals::CollaborativeDraftsController

  subject { my_cell.call(:show) }

  let(:my_cell) { cell("decidim/proposals/collaborative_draft", collaborative_draft, context: context) }

  let(:component) { create(:proposal_component, :with_collaborative_drafts_enabled) }
  let(:author) { create(:user, :confirmed, organization: component.organization) }
  let!(:collaborative_draft) { create(:collaborative_draft, component: component) }
  let(:authors) { create_list(:user, 5, organization: component.organization) }
  let(:collaborative_draft_va) { create(:collaborative_draft, component: component, users: authors) }
  let(:context) {}

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
        within ".card__label" do
          expect.to have_content("COLLABORATIVE DRAFT")
        end
      end
    end

    it "renders the collaborative_draft title and link" do
      within ".card__content" do
        expect.to have_content(collaborative_draft.title)
        href = Decidim::ResourceLocatorPresenter.new(collaborative_draft).path
        expect.to have_link(".card__link", href: href)
      end
    end

    it "renders the footer link" do
      within ".card__footer" do
        expect.to have_content("View Collaborative Draft")
        href = Decidim::ResourceLocatorPresenter.new(collaborative_draft).path
        expect.to have_link(".card__link", href: href)
      end
    end

    it "renders the card author" do
      within ".card__content" do
        expect.to have_content(collaborative_draft.authors)
        expect(subject).to have_css(".author-data--small", count: 1)
      end
    end

    describe "with coauthors" do
      let(:collaborative_draft) { create(:collaborative_draft, component: component, users: authors) }

      it "renders the first three authors" do
        within ".card__content" do
          expect(subject).to have_css(".author-data--small", count: 3)
        end
      end
      it "renders the see_more link" do
        within ".card__content" do
          expect.to have_link(".collapsible-list__see-more")
        end
      end
    end

    context "with open state" do
      let(:collaborative_draft) { create(:collaborative_draft, :open, component: component) }

      it "renders the card with the .success class" do
        expect(subject).to have_css(".card.success")
      end
      it "renders the open state" do
        within ".card__text" do
          expect(subject).to have_css(".success.card__text--status")
          expect.to have_content("open")
        end
      end
    end

    context "with withdrawn state" do
      let(:collaborative_draft) { create(:collaborative_draft, :withdrawn, component: component) }

      it "renders the card with the .alert class" do
        expect(subject).to have_css(".card.alert")
      end
      it "renders the open state" do
        within ".card__text" do
          expect(subject).to have_css(".alert.card__text--status")
          expect.to have_content("withdrawn")
        end
      end
    end

    context "with published state" do
      let(:collaborative_draft) { create(:collaborative_draft, :published, component: component) }

      it "renders the card with the .secondary class" do
        expect(subject).to have_css(".card.secondary")
      end
      it "renders the open state" do
        within ".card__text" do
          expect(subject).to have_css(".secondary.card__text--status")
          expect.to have_content("published")
        end
      end
    end
  end
end
