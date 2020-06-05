# frozen_string_literal: true

require "spec_helper"

describe "Admin manages surveys", type: :system do
  let(:manifest_name) { "surveys" }
  let!(:component) do
    create(:component,
           manifest: manifest,
           participatory_space: participatory_space,
           published_at: nil)
  end
  let!(:questionnaire) { create(:questionnaire) }
  let!(:survey) { create :survey, component: component, questionnaire: questionnaire }

  include_context "when managing a component as an admin"

  it_behaves_like "manage questionnaires"
  it_behaves_like "export survey user answers"
  it_behaves_like "manage announcements"

  context "when survey is not published" do
    before do
      component.unpublish!
    end

    let!(:question) { create(:questionnaire_question, questionnaire: questionnaire) }

    context "when the survey has answers" do
      let!(:answer) { create(:answer, question: question, questionnaire: questionnaire) }

      it "shows warning message" do
        visit questionnaire_edit_path
        expect(page).to have_content("The form is not published")
      end
    end

    it "allows editing questions" do
      visit questionnaire_edit_path
    end

    it "allows to preview survey" do
      visit questionnaire_edit_path
    end

    it "allows to answer survey" do
      visit questionnaire_public_path
    end

    it "deletes answers after editing" do
      visit questionnaire_edit_path
    end

    context "when publishing the survey" do
      let(:clean_after_publish) { true }

      before do
        component.update!(
          step_settings: {
            component.participatory_space.active_step.id => {
              clean_after_publish: clean_after_publish
            }
          }
        )
      end

      context "when clean_after_publish is set to true" do
        it "deletes previous answers afer publishing" do
        end
      end

      context "when clean_after_publish is set to false" do
        let(:clean_after_publish) { false }

        it "does not delete previous answers afer publishing" do
        end
      end
    end
  end

  def questionnaire_edit_path
    manage_component_path(component)
  end

  def questionnaire_public_path
    main_component_path(component)
  end
end
