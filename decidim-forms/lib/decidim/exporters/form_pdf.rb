# frozen_string_literal: true

module Decidim
  module Exporters
    # Inherits from abstract PDF exporter. This class is used to set
    # the parameters used to create a PDF when exporting Survey Responses.
    #
    class FormPDF < PDF
      # i18n-tasks-use t('decidim.admin.exports.formats.FormPDF')
      include ActionView::Helpers::NumberHelper
      include Decidim::Forms::Admin::QuestionnaireResponsesHelper

      class QuestionnaireResponsePresenter < Decidim::Forms::Admin::QuestionnaireResponsePresenter
        def choice(choice_hash)
          render_body_for choice_hash
        end

        delegate :attachments, to: :response

        def body
          return { string: response.body } if response.body.present?
          return { attachments: response.attachments } if response.attachments.any?
          return { string: "-" } if response.choices.empty?

          choices = response.choices.map do |choice|
            {
              response_option_body: choice.try(:response_option).try(:translated_body),
              choice_body: body_or_custom_body(choice)
            }
          end

          return { single_option: choice(choices.first) } if response.question.question_type == "single_option"

          { multiple_option: choices.map { |c| choice(c) } }
        end
      end

      class ParticipantPresenter < Decidim::Forms::Admin::QuestionnaireParticipantPresenter
        def responses
          siblings.map { |response| QuestionnaireResponsePresenter.new(response:) }
        end
      end

      protected

      def add_data!
        composer.text(decidim_sanitize(translated_attribute(questionnaire.title), strip_tags: true), style: :h1)
        composer.text(decidim_sanitize(translated_attribute(questionnaire.description), strip_tags: true), style: :description)
        composer.text(I18n.t("title", scope: "decidim.forms.admin.questionnaires.responses.index", total: collection.count), style: :section_title)

        local_collection = collection.map { |response| ParticipantPresenter.new(participant: response.first) }

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
          question_response: { font:, margin: [10, 0, 10, 0], font_size: 10 },
          file_info: { font:, margin: [10, 0, 10, 0], font_size: 8 },
          link: { font:, margin: [10, 0, 10, 0], font_size: 10, underline: true }
        }
      end

      def header
        [
          layout.text(I18n.t("session_token", scope: "decidim.forms.user_responses_serializer"), style: :th),
          layout.text(I18n.t("user_status", scope: "decidim.forms.user_responses_serializer"), style: :th),
          layout.text(I18n.t("ip_hash", scope: "decidim.forms.user_responses_serializer"), style: :th),
          layout.text(I18n.t("completion", scope: "decidim.forms.user_responses_serializer"), style: :th),
          layout.text(I18n.t("created_at", scope: "decidim.forms.user_responses_serializer"), style: :th)
        ]
      end

      def add_user_data(record)
        cells = [
          layout.text(record.session_token, style: :td),
          layout.text(record.status, style: :td),
          layout.text(record.ip_hash, style: :td),
          layout.text(display_percentage(record.completion), style: :td),
          layout.text(I18n.l(record.responded_at, format: :short), style: :td)
        ]
        composer.table([cells], header: ->(_table) { [header] }, cell_style: { border: { width: 0 } })
      end

      def add_response_box(record, index)
        composer.text(I18n.t("title", number: index + 1, scope: "decidim.forms.admin.questionnaires.responses.export.response"), style: :section_title)
        add_user_data(record)

        record.responses.each do |response|
          composer.text(response.question, style: :question_title)
          add_response_body(response)
        end
      end

      def add_response_body(response)
        return composer.text(response.body[:string], style: :question_response) if response.body.has_key?(:string)

        if response.attachments.any?
          composer.list(marker_type: :disc) do |sub_list|
            response.attachments.each do |attachment|
              sub_list.formatted_text(
                [{ link: attachment.url,
                   text: translated_attribute(attachment.title).presence ||
                    I18n.t("download_attachment", scope: "decidim.forms.questionnaire_response_presenter"),
                   style: :link },
                 " (#{attachment.file_type} #{number_to_human_size(attachment.file_size)})"],
                style: :file_info
              )
            end
          end
          return
        end

        if response.body.has_key?(:single_option)
          composer.list(marker_type: :disc) do |sub_list|
            sub_list.text(response.body[:single_option], style: :question_response)
          end
        else
          composer.list(marker_type: :disc) do |sub_list|
            response.body[:multiple_option].map { |choice| sub_list.text(choice, style: :question_response) }
          end
        end
      end
    end
  end
end
