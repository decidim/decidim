# frozen_string_literal: true

require "spec_helper"

describe "Admin manages questions", type: :system do
  let(:election) { create :election, component: current_component }
  let(:question) { create :question, election: election }
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
    click_on "New Question"

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

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My question")
    end
  end

  context "when the election has already started" do
    let(:election) { create :election, :started, component: current_component }

    it "doesn't create a new question" do
      click_on "New Question"

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

      within ".callout-wrapper" do
        expect(page).to have_content("has already started")
      end
    end
  end

  context "when the election has created on the bulletin board" do
    let(:election) { create(:election, :created, component: current_component) }

    it "cannot add a new question" do
      expect(page).to have_no_content("New Question")
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

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My new question")
      end
    end

    context "when the election has created on the bulletin board" do
      let(:election) { create(:election, :created, component: current_component) }

      it "cannot update the question" do
        within find("tr", text: translated(question.title)) do
          expect(page).to have_no_selector(".action-icon--edit")
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

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).not_to have_content(translated(question.title))
      end
    end

    context "when the election has created on the bulletin board" do
      let(:election) { create(:election, :created, component: current_component) }

      it "cannot delete the question" do
        within find("tr", text: translated(question.title)) do
          expect(page).to have_no_selector(".action-icon--remove")
        end
      end
    end
  end
end
