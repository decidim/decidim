# frozen_string_literal: true

if !Rails.env.production? || ENV.fetch("SEED", nil)
  print "Creating seeds for decidim-templates...\n" unless Rails.env.test?

  require "decidim/faker/localized"

  # Since we usually migrate and seed in the same process, make sure
  # that we don't have invalid or cached information after a migration.
  decidim_tables = ActiveRecord::Base.connection.tables.select do |table|
    table.starts_with?("decidim_")
  end
  decidim_tables.map do |table|
    table.tr("_", "/").classify.safe_constantize
  end.compact.each(&:reset_column_information)

  organization = Decidim::Organization.first

  questionnaire_template = Decidim::Templates::Template.create!(
    organization: organization,
    name: Decidim::Faker::Localized.sentence(word_count: 2),
    description: Decidim::Faker::Localized.paragraph
  )

  questionnaire = Decidim::Forms::Questionnaire.create!(
    questionnaire_for: questionnaire_template,
    title: Decidim::Faker::Localized.paragraph,
    description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.paragraph(sentence_count: 3)
    end,
    tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.paragraph(sentence_count: 2)
    end
  )

  %w(short_answer long_answer).each_with_index do |text_question_type, index|
    Decidim::Forms::Question.create!(
      questionnaire: questionnaire,
      body: Decidim::Faker::Localized.paragraph,
      question_type: text_question_type,
      position: index
    )
  end

  %w(single_option multiple_option).each_with_index do |multiple_choice_question_type, index|
    question = Decidim::Forms::Question.create!(
      questionnaire: questionnaire,
      body: Decidim::Faker::Localized.paragraph,
      question_type: multiple_choice_question_type,
      position: index + 2
    )

    3.times do
      question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
    end

    question.display_conditions.create!(
      condition_question: questionnaire.questions.find_by(position: question.position - 2),
      question: question,
      condition_type: :answered,
      mandatory: true
    )
  end

  %w(matrix_single matrix_multiple).each do |matrix_question_type|
    question = Decidim::Forms::Question.create!(
      questionnaire: questionnaire,
      body: Decidim::Faker::Localized.paragraph,
      question_type: matrix_question_type
    )

    3.times do |idx|
      question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
      question.matrix_rows.create!(body: Decidim::Faker::Localized.sentence, position: idx)
    end
  end

  questionnaire_template.update!(templatable: questionnaire)
end
