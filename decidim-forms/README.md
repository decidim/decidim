# Decidim::Forms

This gem encapsulates the logic to create and manage forms, so it can be reused in other modules, like surveys and meetings.

## Installation

Add this line to your module's gemspec:

```ruby
s.add_dependency "decidim-forms", Decidim::YourModule.version
```

And then execute:

```bash
bundle
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).

## Seeds

Since questionnaires cannot exist without a real model we are not including specific seeds for this engine.

Other engines are free to include questionnaires on their seeds like this:

```ruby
Decidim::Forms::Questionnaire.new(
  title: Decidim::Faker::Localized.paragraph,
  description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
    Decidim::Faker::Localized.paragraph(3)
  end,
  tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
    Decidim::Faker::Localized.paragraph(2)
  end,
)

Decidim::Surveys::Survey.create!(component: component, questionnaire: questionnaire)

%w(short_answer long_answer).each do |text_question_type|
  Decidim::Forms::Question.create!(
    questionnaire: questionnaire,
    body: Decidim::Faker::Localized.paragraph,
    question_type: text_question_type
  )
end

%w(single_option multiple_option).each do |multiple_choice_question_type|
  question = Decidim::Forms::Question.create!(
    questionnaire: questionnaire,
    body: Decidim::Faker::Localized.paragraph,
    question_type: multiple_choice_question_type
  )

  3.times do
    question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
  end
end
```
