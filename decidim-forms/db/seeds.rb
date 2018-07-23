# frozen_string_literal: true

# Since questionnaires cannot exist without a real model we are not including
# specific seeds for this engine.
# Other engines are free to include questionnaires on their seeds like this:
#
# n.times do
#   Decidim::Forms::Questionnaire.create!(
#     title: Decidim::Faker::Localized.paragraph,
#     description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
#       Decidim::Faker::Localized.paragraph(3)
#     end,
#     tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
#       Decidim::Faker::Localized.paragraph(2)
#     end,
#     questionnaire_for: questionnaire_for
#   )
#
#   %w(short_answer long_answer).each do |text_question_type|
#     Decidim::Forms::Question.create!(
#       questionnaire: questionnaire,
#       body: Decidim::Faker::Localized.paragraph,
#       question_type: text_question_type
#     )
#   end
#
#   %w(single_option multiple_option).each do |multiple_choice_question_type|
#     question = Decidim::Forms::Question.create!(
#       questionnaire: questionnaire,
#       body: Decidim::Faker::Localized.paragraph,
#       question_type: multiple_choice_question_type
#     )
#     3.times do
#       question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
#     end
#   end
# end
