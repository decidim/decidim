# frozen_string_literal: true

require "spec_helper"

describe "Admin manages answers", type: :system do
  let!(:proposals) { create_list :proposal, 3, :accepted, component: origin_component }
  let!(:origin_component) { create :proposal_component, participatory_space: current_component.participatory_space }
  let(:election) { create :election, component: current_component }
  let(:question) { create :question, election: }
  let(:answer) { create :election_answer, question: }
  let(:manifest_name) { "elections" }

  include_context "when managing a component as an admin"

  before do
    answer
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(election.title)) do
      page.find(".action-icon--manage-questions").click
    end

    within find("tr", text: translated(question.title)) do
      page.find(".action-icon--manage-answers").click
    end
  end

  describe "importing proposals" do
    it "imports proposals" do
      click_on "Import proposals to answers"

      within ".import_proposals" do
        select origin_component.name["en"], from: :proposals_import_origin_component_id
        check :proposals_import_import_all_accepted_proposals
      end

      click_button "Import proposals to answers"

      expect(page).to have_content("3 proposals successfully imported")
    end
  end

  describe "admin form" do
    before { click_on "New Answer" }

    it_behaves_like "having a rich text editor", "new_answer", "full"
  end

  it "creates a new answer" do
    click_on "New Answer"

    within ".new_answer" do
      fill_in_i18n(
        :answer_title,
        "#answer-title-tabs",
        en: "My answer",
        es: "Mi respuesta",
        ca: "La meva resposta"
      )
      fill_in_i18n_editor(
        :answer_description,
        "#answer-description-tabs",
        en: "Long description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )
    end

    within ".new_answer" do
      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My answer")
    end
  end

  context "when the election was created on the bulletin board" do
    let(:election) { create(:election, :created, component: current_component) }

    it "cannot add a new answer" do
      expect(page).to have_no_content("New Answer")
    end
  end

  context "when max selections is higher than answers count" do
    let(:question) { create :question, election:, max_selections: 5 }

    it "shows alert" do
      expect(page).to have_content("You need 4 more answer/s")
    end
  end

  describe "updating an answer" do
    it "updates an answer" do
      within find("tr", text: translated(answer.title)) do
        page.find(".action-icon--edit").click
      end

      within ".edit_answer" do
        fill_in_i18n(
          :answer_title,
          "#answer-title-tabs",
          en: "My new answer",
          es: "Mi nueva respuesta",
          ca: "La meva nova resposta"
        )

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My new answer")
      end
    end

    context "when the election was created on the bulletin board" do
      let(:election) { create(:election, :created, component: current_component) }

      it "cannot update the answer" do
        within find("tr", text: translated(answer.title)) do
          expect(page).to have_no_selector(".action-icon--edit")
        end
      end
    end
  end

  describe "deleting an answer" do
    it "deletes an answer" do
      within find("tr", text: translated(answer.title)) do
        accept_confirm do
          page.find(".action-icon--remove").click
        end
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).not_to have_content(translated(answer.title))
      end
    end

    context "when the election was created on the bulletin board" do
      let(:election) { create(:election, :created, component: current_component) }

      it "cannot delete the question" do
        within find("tr", text: translated(answer.title)) do
          expect(page).to have_no_selector(".action-icon--remove")
        end
      end
    end
  end

  context "when answer has votes" do
    let!(:election) { create :election, :tally_ended, component: current_component }
    let!(:question) { election.questions.first }
    let!(:answer) { question.answers.first }

    it "shows the votes and selected columns" do
      expect(page).to have_content("Votes")
      expect(page).to have_content("Selected")
    end

    it "can change selected status" do
      within find("tr", text: translated(answer.title)) do
        expect(page).to have_selector(".action-icon")
      end
    end

    it "toggles selected status" do
      within find("tr", text: translated(answer.title)) do
        expect(page).to have_content("Not selected")
      end

      within find("tr", text: translated(answer.title)) do
        first(".action-icon").click
      end

      within find("tr", text: translated(answer.title)) do
        expect(page).to have_content("Selected")
      end

      within ".callout-wrapper" do
        expect(page).to have_content("Answer successfully selected")
      end
    end
  end
end
