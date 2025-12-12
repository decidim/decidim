# frozen_string_literal: true

require "spec_helper"

describe "Proposals Breadcrumb" do
  include_context "with a component"

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, :with_steps, :published, organization:, title: { "en" => "Participatory space" }) }
  let(:component) { create(:proposal_component, :published, :with_amendments_enabled, participatory_space:, name: { "en" => "Component" }) }
  let(:proposal) { create(:proposal, component:, title: { "en" => "Proposal" }) }
  let(:router) { Decidim::EngineRouter.main_proxy(component) }

  before do
    switch_to_host(organization.host)
  end

  describe "index" do
    it "shows the correct information in breadcrumb (space, component)" do
      visit router.root_path(locale: I18n.locale)

      within ".menu-bar" do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
      end
    end
  end

  describe "show" do
    it "shows the correct information in breadcrumb (space, component, proposal)" do
      visit router.proposal_path(proposal, locale: I18n.locale)

      within ".menu-bar" do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(proposal.title))
      end
    end

    context "when it is an official proposal" do
      let(:content) { generate_localized_title }
      let!(:official_proposal) { create(:proposal, :official, body: content, component:) }
      let!(:official_proposal_title) { translated(official_proposal.title) }

      before do
        visit_component
        click_on official_proposal_title
      end

      it "shows the correct information in breadcrumb (space, component, proposal)" do
        within(".menu-bar") do
          expect(page).to have_content(translated(component.participatory_space.title))
          expect(page).to have_content(translated(component.name))
          expect(page).to have_content(translated(official_proposal.title))
        end
      end
    end
  end

  describe "versions", versioning: true do
    let!(:amendment) { create(:amendment, amendable: proposal, emendation:) }
    let!(:emendation) { create(:proposal, body: { en: "Amended One liner body" }, component:) }

    let(:form) do
      Decidim::Amendable::ReviewForm.from_params(
        id: amendment.id,
        amendable_gid: proposal.to_sgid.to_s,
        emendation_gid: emendation.to_sgid.to_s,
        emendation_params: { title: emendation.title, body: emendation.body }
      )
    end
    let(:command) { Decidim::Amendable::Accept.new(form) }

    before do
      visit router.proposal_path(proposal, locale: I18n.locale)
      command.call
      click_on "see other versions"
      click_on("Version 2 of 2")
    end

    it "shows the correct information in breadcrumb (space, component, proposal)" do
      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(proposal.reload.title))
      end
    end
  end

  context "when visiting single amendment page", versioning: true do
    let!(:emendation) { create(:proposal, title: { en: "Amended Long enough title" }, component:) }
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

    before do
      component.update!(settings: { amendments_enabled: true })
      command.call
    end

    it "shows the correct information in breadcrumb (space, component, amendment)" do
      visit router.proposal_path(emendation, locale: I18n.locale)

      within ".menu-bar" do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(emendation.title))
        expect(page).to have_content("Amendment")
      end
    end
  end
end
