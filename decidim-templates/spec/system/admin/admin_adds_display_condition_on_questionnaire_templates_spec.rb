# frozen_string_literal: true

require "spec_helper"

describe "Admin adds display condition to template's questionnaire question" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:template) { create(:questionnaire_template, organization:) }
  let(:matrix_rows) { Array.new(2) { { "body" => Decidim::Faker::Localized.sentence } } }
  let(:answer_options) { Array.new(2) { { "body" => Decidim::Faker::Localized.sentence } } }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "adds display condition to questionnaire question" do
    questionnaire = template.templatable
    question_one = create(:questionnaire_question, mandatory: true, question_type: "matrix_single", rows: matrix_rows, options: answer_options, questionnaire:)
    question_two = create(:questionnaire_question, :with_answer_options, questionnaire:)

    visit decidim_admin_templates.edit_questionnaire_path(template.id)
    # expand question two
    find("[data-controls=panel-questionnaire_question_#{question_two.id}-question-card]").click
    # add display condition
    find(".add-display-condition").click
    # select question
    select translated(question_one.body), from: "questionnaire[questions][#{question_two.id}][display_conditions][questionnaire-display-condition-id][decidim_condition_question_id]"
    # select equal
    select "Equal", from: "questionnaire[questions][#{question_two.id}][display_conditions][questionnaire-display-condition-id][condition_type]"
    # validate we have the 2 answer options from question one in the select
    select = find("#questionnaire_questions_#{question_two.id}_display_conditions_questionnaire-display-condition-id_decidim_answer_option_id")
    expect(select).to have_content(translated(question_one.answer_options.first.body))
    expect(select).to have_content(translated(question_one.answer_options.last.body))
  end
end
