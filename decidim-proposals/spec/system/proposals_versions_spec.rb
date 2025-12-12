# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", versioning: true do
  include_context "with a component"
  let(:component) { create(:proposal_component, organization:) }
  let!(:proposal) { create(:proposal, body: { en: "One liner body" }, component:) }
  let!(:emendation) { create(:proposal, body: { en: "Amended One liner body" }, component:) }
  let!(:amendment) { create(:amendment, amendable: proposal, emendation:) }

  let(:form) do
    Decidim::Amendable::ReviewForm.from_params(
      id: amendment.id,
      amendable_gid: proposal.to_sgid.to_s,
      emendation_gid: emendation.to_sgid.to_s,
      emendation_params: { title: emendation.title, body: emendation.body }
    )
  end
  let(:command) { Decidim::Amendable::Accept.new(form) }

  let(:proposal_path) { Decidim::ResourceLocatorPresenter.new(proposal).path }

  context "when visiting a proposal details" do
    before do
      visit proposal_path
    end

    it "has only one version" do
      expect(page).to have_content("Version number 1 (of 1)")
    end

    it "shows the versions index" do
      expect(page).to have_link "see other versions"
    end

    context "when accepting an amendment" do
      before do
        command.call
        visit proposal_path
      end

      it "creates a new version" do
        expect(page).to have_content("Version number 2 (of 2)")
      end
    end
  end

  context "when visiting versions index" do
    before do
      visit proposal_path
      command.call
      click_on "see other versions"
    end

    it "lists all versions" do
      expect(page).to have_link("Version 1 of 2")
      expect(page).to have_link("Version 2 of 2")
    end
  end

  context "when showing a version of a proposal that is hidden" do
    let!(:proposal) { create(:proposal, :published, body: { en: "One liner body" }, component:) }

    include_examples "a version of a hidden object" do
      let(:resource_path) { proposal_path }
      let(:hidden_object) { proposal }
    end
  end

  context "when showing version" do
    before do
      visit proposal_path
      command.call
      click_on "see other versions"
      click_on("Version 2 of 2")
    end

    it_behaves_like "accessible page"

    it "shows the creation date" do
      within ".version__author" do
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end

    it "shows the changed attributes" do
      expect(page).to have_content("Changes at")

      within "#diff-for-title-english" do
        expect(page).to have_content("Title (English)")

        within ".diff > ul > .del" do
          expect(page).to have_content(translated(proposal.title))
        end

        within ".diff > ul > .ins" do
          expect(page).to have_content(translated(emendation.title))
        end
      end

      within "#diff-for-body-english" do
        expect(page).to have_content("Body (English)")

        within ".diff > ul > .del" do
          expect(page).to have_content(translated(proposal.body))
        end

        within ".diff > ul > .ins" do
          expect(page).to have_content(translated(emendation.body))
        end
      end
    end

    it "show the correct state" do
      form_params = {
        internal_state: "evaluating",
        answer: { en: "Foo" },
        cost: 2000,
        cost_report: { en: "Cost report" },
        execution_period: { en: "Execution period" }
      }
      form = Decidim::Proposals::Admin::ProposalAnswerForm.from_params(form_params).with_context(
        current_user: proposal.authors.first,
        current_component: proposal.component,
        current_organization: proposal.component.organization
      )
      Decidim::Proposals::Admin::AnswerProposal.call(form, proposal)

      visit current_path
      click_on("Version 3 of 3")

      within "#diff-for-state" do
        expect(page).to have_content("State")
        within ".diff > ul > .ins" do
          expect(page).to have_content("Evaluating")
        end
      end
    end
  end
end
