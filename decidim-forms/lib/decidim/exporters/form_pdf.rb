# frozen_string_literal: true

module Decidim
  module Exporters
    # Inherits from abstract PDF exporter. This class is used to set
    # the parameters used to create a PDF when exporting Survey Answers.
    #
    class FormPDF < PDF
      # i18n-tasks-use t('decidim.admin.exports.formats.FormPDF')
      include ActionView::Helpers::NumberHelper
      include Decidim::Forms::Admin::QuestionnaireAnswersHelper

      class QuestionnaireAnswerPresenter < Decidim::Forms::Admin::QuestionnaireAnswerPresenter
        def choice(choice_hash)
          render_body_for choice_hash
        end

        delegate :attachments, to: :answer

        def body
          return { string: answer.body } if answer.body.present?
          return { attachments: answer.attachments } if answer.attachments.any?
          return { string: "-" } if answer.choices.empty?

          choices = answer.choices.map do |choice|
            {
              answer_option_body: choice.try(:answer_option).try(:translated_body),
              choice_body: body_or_custom_body(choice)
            }
          end

          return { single_option: choice(choices.first) } if answer.question.question_type == "single_option"

          { multiple_option: choices.map { |c| choice(c) } }
        end
      end

      class ParticipantPresenter < Decidim::Forms::Admin::QuestionnaireParticipantPresenter
        def answers
          siblings.map { |answer| QuestionnaireAnswerPresenter.new(answer:) }
        end
      end

      protected

      def add_data!
        composer.text(decidim_sanitize(translated_attribute(questionnaire.title), strip_tags: true), style: :h1)
        composer.text(decidim_sanitize(translated_attribute(questionnaire.description), strip_tags: true), style: :description)
        composer.text(I18n.t("title", scope: "decidim.forms.admin.questionnaires.answers.index", total: collection.count), style: :section_title)

        local_collection = collection.map { |answer| ParticipantPresenter.new(participant: answer.first) }

        local_collection.each_with_index do |record, index|
          add_response_box(record, index)
        end
      end

      def questionnaire = collection.first.first.questionnaire

      def styles
        {
          h1: { font: bold_font, font_size: 18, margin: [0, 0, 10, 0] },
          th: { font: bold_font, font_size: 10, margin: [0, 0, 10, 0] },
          td: { font:, font_size: 10, margin: [0, 0, 10, 0] },
          description: { font:, margin: [0, 0, 10, 0], font_size: 10 },
          section_title: { font: bold_font, margin: [15, 0, 15, 0], font_size: 16 },
          question_title: { font: bold_font, margin: [10, 0, 10, 0], font_size: 12 },
          question_answer: { font:, margin: [10, 0, 10, 0], font_size: 10 },
          file_info: { font:, margin: [10, 0, 10, 0], font_size: 8 },
          link: { font:, margin: [10, 0, 10, 0], font_size: 10, underline: true }
        }
      end

      def header
        [
          layout.text(I18n.t("session_token", scope: "decidim.forms.user_answers_serializer"), style: :th),
          layout.text(I18n.t("user_status", scope: "decidim.forms.user_answers_serializer"), style: :th),
          layout.text(I18n.t("ip_hash", scope: "decidim.forms.user_answers_serializer"), style: :th),
          layout.text(I18n.t("completion", scope: "decidim.forms.user_answers_serializer"), style: :th),
          layout.text(I18n.t("created_at", scope: "decidim.forms.user_answers_serializer"), style: :th)
        ]
      end

      def add_user_data(record)
        cells = [
          layout.text(record.session_token, style: :td),
          layout.text(record.status, style: :td),
          layout.text(record.ip_hash, style: :td),
          layout.text(display_percentage(record.completion), style: :td),
          layout.text(I18n.l(record.answered_at, format: :short), style: :td)
        ]
        composer.table([cells], header: ->(_table) { [header] }, cell_style: { border: { width: 0 } })
      end

      def add_response_box(record, index)
        composer.text(I18n.t("title", number: index + 1, scope: "decidim.forms.admin.questionnaires.answers.export.answer"), style: :section_title)
        add_user_data(record)

        record.answers.each do |answer|
          composer.text(answer.question, style: :question_title)
          add_answer_body(answer)
        end
      end

      def add_answer_body(answer)
        return composer.text(answer.body[:string], style: :question_answer) if answer.body.has_key?(:string)

        if answer.attachments.any?
          composer.list(marker_type: :disc) do |sub_list|
            answer.attachments.each do |attachment|
              sub_list.formatted_text(
                [{ link: attachment.url,
                   text: translated_attribute(attachment.title).presence ||
                    I18n.t("download_attachment", scope: "decidim.forms.questionnaire_answer_presenter"),
                   style: :link },
                 " (#{attachment.file_type} #{number_to_human_size(attachment.file_size)})"],
                style: :file_info
              )
            end
          end
          return
        end

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
    end
  end
end
