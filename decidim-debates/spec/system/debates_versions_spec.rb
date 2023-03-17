# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", versioning: true, type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }
  let!(:debate) { create(:debate, component:) }
  let(:debate_path) { Decidim::ResourceLocatorPresenter.new(debate).path }

  context "when visiting a debate details" do
    before do
      visit debate_path
    end

    it "has only one version" do
      expect(page).to have_content("Version number 1 (of 1)")
    end

    it "shows the versions index" do
      expect(page).to have_link "see other versions"
    end
  end

  context "when visiting versions index" do
    before do
      update_debate
      visit debate_path
      click_link "see other versions"
    end

    it "lists all versions" do
      expect(page).to have_link("Version 2 of 2")
      expect(page).to have_link("Version 1 of 2")
    end
  end

  context "when showing version" do
    before do
      visit debate_path
      update_debate
      click_link "see other versions"
      click_link("Version 2 of 2")
    end

    # REDESIGN_PENDING: The accessibility should be tested after complete redesign
    # it_behaves_like "accessible page"

    it "allows going back to the debate" do
      click_link "Back"
      expect(page).to have_current_path debate_path
    end

    it "allows going back to the versions list" do
      skip "REDESIGN_PENDING: Once redesigned this page will contain a call to the versions_list cell with links to each one"

      click_link "Show all versions"
      expect(page).to have_current_path "#{debate_path}/versions"
    end

    it "shows the creation date" do
      within ".version__author" do
        skip_unless_redesign_enabled("This test pass using redesigned author cell")

        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end

    it "shows the changed attributes" do
      expect(page).to have_content("Changes at")

      within "#diff-for-title-english" do
        expect(page).to have_content("Title")

        within ".diff > ul > .ins" do
          expect(page).to have_content(debate.title["en"])
        end
      end

      within "#diff-for-description-english" do
        expect(page).to have_content("Description")

        within ".diff > ul > .ins" do
          expect(page).to have_content(debate.description["en"])
        end
      end
    end
  end

  def update_debate
    form = Decidim::Debates::Admin::DebateForm.from_params(
      debate.attributes.with_indifferent_access.merge(
        title: { "en" => "New title" },
        description: { "en" => "New description" },
        instructions: { "en" => "New instructions" }
      )
    ).with_context(
      current_organization: organization,
      current_participatory_space: component.participatory_space,
      current_component: component
    )

    Decidim::Debates::Admin::UpdateDebate.call(form, debate)
  end
end
