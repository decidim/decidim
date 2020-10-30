# frozen_string_literal: true

require "spec_helper"

describe "Admin manages elections", type: :system do
  subject { described_class.new(params) }

  let(:params) do
    {
      identification_private_key: identification_private_key,
      server: server,
      api_key: api_key,
      scheme: scheme,
      authority_name: authority_name
    }
  end

  let(:identification_private_key) { identification_private_key_content }
  let(:server) { "https://bb.example.org" }
  let(:api_key) { Random.urlsafe_base64(30) }
  let(:scheme) do
    {
      name: "test",
      parameters: {
        quorum: 2
      }
    }
  end
  let(:authority_name) { "Decidim Test Authority" }
  let(:election_data) do
    {
      schema: scheme,
      election_id: authority_name
    }
  end

  let(:identification_private_key_content) do
    <<~KEY
      -----BEGIN RSA PRIVATE KEY-----
      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
      -----END RSA PRIVATE KEY-----
    KEY
  end

  let(:election) { create :election, :upcoming, :published, component: current_component }
  let(:manifest_name) { "elections" }

  include_context "when managing a component as an admin"
  before do
    election
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  it_behaves_like "manage announcements"

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

  describe "set up an election" do
    context "when the election is published" do
      let!(:election) { create :election, :upcoming, :published, :ready_for_setup, component: current_component }

      it "sets up an election" do
        within find("tr", text: translated(election.title)) do
          page.find(".action-icon--setup-election").click
        end

        within ".setup_election" do
          expect(page).to have_css(".card-title", text: "Election setup")
          expect(page).to have_content("The election is published")
          expect(page).to have_content("The setup is being done at least 3 hours before the election starts")
          expect(page).to have_content("The election has at least 1 question")
          expect(page).to have_content("Each question has at least 2 answers")
          expect(page).to have_content("All the questions have a correct value for maximum of answers")
          expect(page).to have_content("The size of this list of trustees is correct and it will be needed at least #{scheme[:parameters][:quorum]} trustees to perform the tally process")
          scheme[:parameters][:quorum].times do
            expect(page).to have_content("valid public key")
          end

          page.find(".button").click
        end
        expect(page).to have_admin_callout("successfully")
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
end
