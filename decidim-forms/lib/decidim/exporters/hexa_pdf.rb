# frozen_string_literal: true

require "decidim/forms"

require "hexapdf"

module Decidim
  module Exporters
    class HexaPDF < Exporter
      include Decidim::TranslatableAttributes
      include Decidim::SanitizeHelper
      include ActionView::Helpers::NumberHelper
      include Decidim::Forms::Admin::QuestionnaireAnswersHelper

      class QuestionnaireAnswerPresenter < Decidim::Forms::Admin::QuestionnaireAnswerPresenter

        def choice(choice_hash)
          render_body_for choice_hash
        end
        def body
          return { string: answer.body} if answer.body.present?
          return { attachments: attachments } if answer.attachments.any?
          return { string: "-" } if answer.choices.empty?

          choices = answer.choices.map do |choice|
            {
              answer_option_body: choice.try(:answer_option).try(:translated_body),
              choice_body: body_or_custom_body(choice)
            }
          end

          return { single_option: choice(choices.first)} if answer.question.question_type == "single_option"

          { multiple_option:  choices.map { |c| choice(c) } }
        end
      end
      class ParticipantPresenter < Decidim::Forms::Admin::QuestionnaireParticipantPresenter
        def answers
          siblings.map { |answer| QuestionnaireAnswerPresenter.new(answer:) }
        end
      end

      def export
        questionnaire = collection.first.first.questionnaire

        ::HexaPDF::Composer.create("table_box.pdf") do |composer|
          composer.styles(
            h1: { font: composer.document.fonts.add(font_family, variant: :bold), font_size: 18, margin: [0, 0, 10, 0] },
            th: { font: composer.document.fonts.add(font_family, variant: :bold), font_size: 10, margin: [0, 0, 10, 0] },
            td: { font: composer.document.fonts.add(font_family), font_size: 10, margin: [0, 0, 10, 0] },
            description: { font: composer.document.fonts.add(font_family), margin: [0, 0, 10, 0], font_size: 10 },
            section_title: { font: composer.document.fonts.add(font_family, variant: :bold), margin: [15, 0, 15, 0], font_size: 16 },
            question_title: { font: composer.document.fonts.add(font_family, variant: :bold), margin: [10, 0, 10, 0], font_size: 12 },
            question_answer: { font: composer.document.fonts.add(font_family), margin: [10, 0, 10, 0], font_size: 10 }
          )

          composer.text(translated_attribute(questionnaire.title), style: :h1)
          composer.text(decidim_sanitize_translated(questionnaire.description), style: :description)
          composer.text(I18n.t("question.title", scope:, count: collection.count), style: :section_title)

          local_collection = collection.map { |answer| ParticipantPresenter.new(participant: answer.first) }

          local_collection.each_with_index do |record, index|
            add_response_box(composer, record, index)
          end
        end
      end

      private

      def add_user_data(composer, record)
        layout = composer.document.layout
        header = [
          layout.text(I18n.t("session_token", scope: "decidim.forms.user_answers_serializer"), style: :th),
          layout.text(I18n.t("user_status", scope: "decidim.forms.user_answers_serializer"), style: :th),
          layout.text(I18n.t("ip_hash", scope: "decidim.forms.user_answers_serializer"), style: :th),
          layout.text(I18n.t("completion", scope: "decidim.forms.user_answers_serializer"), style: :th),
          layout.text(I18n.t("created_at", scope: "decidim.forms.user_answers_serializer"), style: :th)
        ]
        cells = [
          [
            layout.text(record.session_token, style: :td),
            layout.text(record.status, style: :td),
            layout.text(record.ip_hash, style: :td),
            layout.text(display_percentage(record.completion), style: :td),
            layout.text(I18n.l(record.answered_at, format: :short), style: :td)
          ]
        ]
        composer.table(cells, header: ->(_table) { [header] }, cell_style: { border: { width: 0 } })
      end

      def add_response_box(composer, record, index)
        composer.text(I18n.t("question.response", scope:, number: index + 1), style: :section_title)
        add_user_data(composer, record)

        record.answers.each do |answer|
          composer.text(answer.question, style: :question_title)
          add_answer_body(composer, answer)
        end
      end

      def add_answer_body(composer, answer)
        return composer.text(answer.body[:string], style: :question_answer) if answer.body.has_key?(:string)
      # #   return attachments if answer.attachments.any?

        if answer.body.has_key?(:single_option)
          composer.list(marker_type: :disc) do |sub_list|
            sub_list.text(answer.body[:single_option], style: :question_answer)
          end
        else
          composer.list(marker_type: :disc) do |sub_list|
            answer.body[:multiple_option].map { |choice| sub_list.text(choice, style: :question_answer) }
          end
        end
      end

      def font_family = "Times"

      def scope = "decidim.forms.admin.questionnaires.export"
    end
  end
end
