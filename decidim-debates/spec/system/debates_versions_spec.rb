# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", versioning: true do
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

    context "when showing a version of a debate that is hidden" do
      include_examples "a version of a hidden object" do
        let(:resource_path) { debate_path }
        let(:hidden_object) { debate }
      end
    end
  end

  context "when visiting versions index" do
    before do
      update_debate
      visit debate_path
      click_on "see other versions"
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
