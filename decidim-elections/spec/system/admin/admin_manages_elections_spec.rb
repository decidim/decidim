# frozen_string_literal: true

require "spec_helper"

describe "Admin manages elections" do
  let(:election) { create(:election, :upcoming, :published, component: current_component) }
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

  it_behaves_like "manage questionnaires" do
    let(:election) { create(:election, :ongoing, :published, component: current_component) }
  end

  describe "admin form" do
    before { click_on "New election" }

    it_behaves_like "having a rich text editor", "new_election", "full"
  end

  describe "creating an election" do
    it "creates a new election" do
      click_link "New election"

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

      expect(page).to have_content("Check that the organization time zone is correct")
      expect(page).to have_content("The current configuration is UTC")

      fill_in :election_start_time, with: Time.current.change(day: 12, hour: 10, min: 50)
      fill_in :election_end_time, with: Time.current.change(day: 12, hour: 12, min: 50)

      within ".new_election" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("Election successfully created")

      within "table" do
        expect(page).to have_content("My election")
      end
    end

    context "when the organization has a different time zone" do
      let(:organization) { create(:organization, time_zone: "Madrid") }

      it "shows the correct time zone" do
        click_link "New election"

        expect(page).to have_content("Check that the organization time zone is correct")
        expect(page).to have_content("The current configuration is Madrid")
      end
    end
  end

  describe "updating an election" do
    let(:election) { create(:election, :published, component: current_component) }

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

        expect(page).to have_content("Check that the organization time zone is correct")
        expect(page).to have_content("The current configuration is UTC")

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("Election successfully updated")

      within "table" do
        expect(page).to have_content("My new title")
      end
    end

    context "when the organization has a different time zone" do
      let(:organization) { create(:organization, time_zone: "Madrid") }

      it "shows the correct time zone" do
        within find("tr", text: translated(election.title)) do
          page.find(".action-icon--edit").click
        end

        expect(page).to have_content("Check that the organization time zone is correct")
        expect(page).to have_content("The current configuration is Madrid")
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
      let!(:election) { create(:election, :complete, component: current_component) }

      it "publishes the election" do
        within find("tr", text: translated(election.title)) do
          page.find(".action-icon--publish").click
        end

        expect(page).to have_admin_callout("The election has been successfully published")

        within find("tr", text: translated(election.title)) do
          expect(page).not_to have_selector(".action-icon--publish")
        end
      end
    end
  end

  describe "unpublishing an election" do
    let!(:election) { create(:election, :published, :ready_for_setup, component: current_component) }

    it "unpublishes an election" do
      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--unpublish").click
      end

      expect(page).to have_admin_callout("The election has been successfully unpublished")

      within find("tr", text: translated(election.title)) do
        expect(page).not_to have_selector(".action-icon--unpublish")
      end
    end

    context "when the election is ongoing" do
      let!(:election) { create(:election, :started, component: current_component) }

      it "cannot unpublish the election" do
        within find("tr", text: translated(election.title)) do
          expect(page).not_to have_selector(".action-icon--unpublish")
        end
      end
    end

    context "when the election is published and has finished" do
      let!(:election) { create(:election, :published, :finished, component: current_component) }

      it "cannot unpublish the election" do
        within find("tr", text: translated(election.title)) do
          expect(page).not_to have_selector(".action-icon--unpublish")
        end
      end
    end
  end

  describe "deleting an election" do
    let!(:election) { create(:election, component: current_component) }

    it "deletes an election" do
      within find("tr", text: translated(election.title)) do
        accept_confirm do
          page.find(".action-icon--remove").click
        end
      end

      expect(page).to have_admin_callout("Election successfully deleted")

      within "table" do
        expect(page).not_to have_content(translated(election.title))
      end
    end

    context "when the election has created on the bulletin board" do
      let(:election) { create(:election, :created, component: current_component) }

      it "cannot delete the election" do
        within find("tr", text: translated(election.title)) do
          expect(page).not_to have_selector(".action-icon--remove")
        end
      end
    end
  end

  def questionnaire_edit_path
    Decidim::EngineRouter.admin_proxy(current_component).edit_feedback_form_path(id: election.id)
  end

  def questionnaire_public_path
    Decidim::EngineRouter.main_proxy(current_component).election_feedback_path(election)
  end
end
