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

  before do
    allow(controller).to receive(:current_user).and_return(author)
  end

  context "when rendering a collaborative_draft" do
    it "renders the card" do
      expect(subject).to have_css('[id^="proposals__collaborative_draft"]')
    end

    it "renders the collaborative_draft title and link" do
      expect(subject).to have_content(collaborative_draft.title)
      href = Decidim::ResourceLocatorPresenter.new(collaborative_draft).path
      expect(subject).to have_link(href:)
    end

    it "renders the card author" do
      expect(subject).to have_content(collaborative_draft.authors.first.name)
      expect(subject).to have_css("[data-author]", count: 1)
    end

    describe "with coauthors" do
      let(:collaborative_draft) { create(:collaborative_draft, component:, users: authors) }

      it "renders the first three authors" do
        expect(subject).to have_css("[data-author]", count: 3)
      end

      it "indicates number of remaining authors" do
        expect(subject.find("[data-remaining-authors]")).to have_content("+2")
      end
    end

    context "with open state" do
      let(:collaborative_draft) { create(:collaborative_draft, :open, component:) }

      it "renders the card with the .success class" do
        expect(subject).to have_css(".success")
      end

      it "renders the open state" do
        expect(subject).to have_content("Open")
      end
    end

    context "with withdrawn state" do
      let(:collaborative_draft) { create(:collaborative_draft, :withdrawn, component:) }

      it "renders the card with the .alert class" do
        expect(subject).to have_css(".alert")
      end

      it "renders the open state" do
        expect(subject).to have_content("Withdrawn")
      end
    end

    context "with published state" do
      let(:collaborative_draft) { create(:collaborative_draft, :published, component:) }

      it "renders the card with the .success class" do
        expect(subject).to have_css(".success")
      end

      it "renders the open state" do
        expect(subject).to have_content("Published")
      end
    end
  end
end
