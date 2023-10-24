# frozen_string_literal: true

require "spec_helper"

describe "Admin manages questions", type: :system do
  let(:election) { create(:election, component: current_component) }
  let(:question) { create(:question, election:) }
  let(:manifest_name) { "elections" }

  include_context "when managing a component as an admin"

  before do
    question
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(election.title)) do
      page.find(".action-icon--manage-questions").click
    end
  end

  it "creates a new question" do
    click_on "New question"

    within ".new_question" do
      fill_in_i18n(
        :question_title,
        "#question-title-tabs",
        en: "My question",
        es: "Mi pregunta",
        ca: "La meva pregunta"
      )
    end

    within ".new_question" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("Question successfully created.")

    within "table" do
      expect(page).to have_content("My question")
    end
  end

  context "when the election has been created on the bulletin board" do
    let(:election) { create(:election, :created, component: current_component) }

    it "does not create a new question" do
      visit Decidim::EngineRouter.admin_proxy(component).new_election_question_path(election)

      expect(page).to have_admin_callout("You are not authorized to perform this action")
    end

    it "cannot add a new question" do
      expect(page).not_to have_content("New Question")
    end
  end

  describe "updating a question" do
    it "updates a question" do
      within find("tr", text: translated(question.title)) do
        page.find(".action-icon--edit").click
      end

      within ".edit_question" do
        fill_in_i18n(
          :question_title,
          "#question-title-tabs",
          en: "My new question",
          es: "Mi nueva pregunta",
          ca: "La meva nova pregunta"
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("Question successfully updated.")

      within "table" do
        expect(page).to have_content("My new question")
      end
    end

    context "when the election has created on the bulletin board" do
      let(:election) { create(:election, :created, component: current_component) }

      it "cannot update the question" do
        within find("tr", text: translated(question.title)) do
          expect(page).not_to have_selector(".action-icon--edit")
        end
      end
    end
  end

  describe "deleting a question" do
    it "deletes a question" do
      within find("tr", text: translated(question.title)) do
        accept_confirm do
          page.find(".action-icon--remove").click
        end
      end

      expect(page).to have_admin_callout("Question successfully deleted.")

      within "table" do
        expect(page).not_to have_content(translated(question.title))
      end
    end

    context "when the election has created on the bulletin board" do
      let(:election) { create(:election, :created, component: current_component) }

      it "cannot delete the question" do
        within find("tr", text: translated(question.title)) do
          expect(page).not_to have_selector(".action-icon--remove")
        end
      end
    end
  end
end
