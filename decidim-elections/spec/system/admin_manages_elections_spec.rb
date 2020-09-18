# frozen_string_literal: true

require "spec_helper"

describe "Admin manages elections", type: :system do
  let(:election) { create :election, :upcoming, :published, component: current_component }
  let(:questionnaire) { election.questionnaire }
  let(:manifest_name) { "elections" }

  include_context "when managing a component as an admin"

  before do
    election
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  it_behaves_like "manage announcements"

  it_behaves_like "manage questionnaires"

  describe "admin form" do
    before { click_on "New Election" }

    it_behaves_like "having a rich text editor", "new_election", "full"
  end

  it "creates a new election" do
    within ".card-title" do
      page.find(".button.button--title").click
    end

    within ".new_election" do
      fill_in_i18n(
        :election_title,
        "#election-title-tabs",
        en: "My election",
        es: "Mi elección",
        ca: "La meva elecció"
      )
      fill_in_i18n_editor(
        :election_description,
        "#election-description-tabs",
        en: "Long description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )
    end

    page.execute_script("$('#election_start_time').focus()")
    page.find(".datepicker-dropdown .day", text: "12").click
    page.find(".datepicker-dropdown .hour", text: "10:00").click
    page.find(".datepicker-dropdown .minute", text: "10:50").click

    page.execute_script("$('#election_end_time').focus()")
    page.find(".datepicker-dropdown .day", text: "12").click
    page.find(".datepicker-dropdown .hour", text: "12:00").click
    page.find(".datepicker-dropdown .minute", text: "12:50").click

    within ".new_election" do
      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My election")
    end
  end

  describe "updating an election" do
    it "updates an election" do
      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--edit").click
      end

      within ".edit_election" do
        fill_in_i18n(
          :election_title,
          "#election-title-tabs",
          en: "My new title",
          es: "Mi nuevo título",
          ca: "El meu nou títol"
        )

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My new title")
      end
    end
  end

  describe "previewing elections" do
    it "links the election correctly" do
      link = find("a[title=Preview]")
      expect(link[:href]).to include(resource_locator(election).path)
    end
  end

  describe "publishing an election" do
    context "when the election is unpublished" do
      let!(:election) { create(:election, :upcoming, :complete, component: current_component) }

      it "publishes the election" do
        within find("tr", text: translated(election.title)) do
          page.find(".action-icon--publish").click
        end

        within ".callout-wrapper" do
          expect(page).to have_content("successfully")
        end

        within find("tr", text: translated(election.title)) do
          expect(page).to have_no_selector(".action-icon--publish")
        end
      end
    end
  end

  describe "unpublishing an election" do
    it "unpublishes an election" do
      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--unpublish").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within find("tr", text: translated(election.title)) do
        expect(page).to have_no_selector(".action-icon--unpublish")
      end
    end

    context "when the election is ongoing" do
      let!(:election) { create(:election, :started, component: current_component) }

      it "cannot unpublish the election" do
        within find("tr", text: translated(election.title)) do
          expect(page).to have_no_selector(".action-icon--unpublish")
        end
      end
    end

    context "when the election is published and has finished" do
      let!(:election) { create(:election, :published, :finished, component: current_component) }

      it "cannot unpublish the election" do
        within find("tr", text: translated(election.title)) do
          expect(page).to have_no_selector(".action-icon--unpublish")
        end
      end
    end
  end

  describe "deleting an election" do
    it "deletes an election" do
      within find("tr", text: translated(election.title)) do
        accept_confirm do
          page.find(".action-icon--remove").click
        end
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).not_to have_content(translated(election.title))
      end
    end

    context "when the election has started" do
      let!(:election) { create(:election, :started, component: current_component) }

      it "cannot delete the election" do
        within find("tr", text: translated(election.title)) do
          expect(page).to have_no_selector(".action-icon--remove")
        end
      end
    end
  end

  def questionnaire_edit_path
    Decidim::EngineRouter.admin_proxy(current_component).edit_feedback_form_path(id: election.id)
  end

  def questionnaire_public_path
    Decidim::EngineRouter.main_proxy(current_component).election_feedback_path(election_id: election.id)
  end
end
