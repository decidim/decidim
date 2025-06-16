# frozen_string_literal: true

require "decidim/demographics/admin"
require "decidim/demographics/engine"
require "decidim/demographics/admin_engine"

module Decidim
  # This namespace holds the logic of the `Demographics` component. This component
  # allows users to create demographics in a participatory space.
  module Demographics
    # i18n-tasks-use t('decidim.demographics.questions.age.question')
    # i18n-tasks-use t('decidim.demographics.questions.age.options')
    # i18n-tasks-use t('decidim.demographics.questions.gender.question')
    # i18n-tasks-use t('decidim.demographics.questions.gender.options')
    # i18n-tasks-use t('decidim.demographics.questions.postal.question')
    def self.create_default_questionnaire!(questionnaire)
      locales = questionnaire.questionnaire_for.organization.available_locales

      scope = "decidim.demographics.questions"

      first_question = questionnaire.questions.create!(
        position: 0,
        question_type: "single_option",
        body: locales.index_with { |key| I18n.with_locale(key) { I18n.t("age.question", scope:) } }
      )

      I18n.t("age.options", scope:).each_with_index do |_o, index|
        first_question.response_options.create!(body: locales.index_with { |key| I18n.with_locale(key) { I18n.t("age.options", scope:)[index] } }, free_text: false)
      end

      second_question = questionnaire.questions.create!(
        position: 1,
        question_type: "single_option",
        body: locales.index_with { |key| I18n.with_locale(key) { I18n.t("gender.question", scope:) } }
      )

      I18n.t("gender.options", scope:).each_with_index do |_o, index|
        second_question.response_options.create!(body: locales.index_with { |key| I18n.with_locale(key) { I18n.t("gender.options", scope:)[index] } }, free_text: false)
      end

      questionnaire.questions.create!(
        position: 2,
        question_type: "short_response",
        body: locales.index_with { |key| I18n.with_locale(key) { I18n.t("postal.question", scope:) } }
      )
    end
  end
end
