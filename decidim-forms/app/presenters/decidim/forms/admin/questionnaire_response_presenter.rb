# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      #
      # Presenter for questionnaire response
      #
      class QuestionnaireResponsePresenter < SimpleDelegator
        delegate :content_tag, :safe_join, :link_to, :number_to_human_size, to: :view_context

        include Decidim::TranslatableAttributes

        def response
          __getobj__.fetch(:response)
        end

        def view_context
          __getobj__.fetch(:view_context, ActionController::Base.new.view_context)
        end

        def question
          translated_attribute(response.question.body)
        end

        def body
          return response.body if response.body.present?
          return attachments if response.attachments.any?
          return "-" if response.choices.empty?

          choices = build_choices

          render_choices_list(choices)
        end

        private

        def build_choices
          response.choices.map do |choice|
            matrix_row_body = matrix_row_body_for(choice)
            {
              response_option_body: choice.try(:response_option).try(:translated_body),
              choice_body: body_or_custom_body(choice),
              matrix_row_body:
            }
          end
        end

        def matrix_row_body_for(choice)
          return unless response.question.matrix?
          return unless choice.matrix_row&.body

          translated_attribute(choice.matrix_row.body)
        end

        def render_choices_list(choices)
          content_tag(:ul) do
            if response.question.question_type == "single_option"
              choice(choices.first)
            else
              safe_join(choices.map { |c| choice(c) })
            end
          end
        end

        def attachments
          content_tag(:ul) do
            safe_join(response.attachments.map { |a| pretty_attachment(a) })
          end
        end

        private

        def pretty_attachment(attachment)
          # rubocop:disable Style/StringConcatenation
          # Interpolating strings that are `html_safe` is problematic with Rails.
          content_tag :li do
            link_to(attachment.url, target: "_blank", rel: "noopener noreferrer") do
              content_tag(:span) do
                translated_attribute(attachment.title).presence ||
                  I18n.t("download_attachment", scope: "decidim.forms.questionnaire_response_presenter")
              end + " " + content_tag(:small) do
                "#{attachment.file_type} #{number_to_human_size(attachment.file_size)}"
              end
            end
          end
          # rubocop:enable Style/StringConcatenation
        end

        def choice(choice_hash)
          content_tag :li do
            if choice_hash[:matrix_row_body].present?
              content_tag(:strong, choice_hash[:matrix_row_body]) + ": " + render_body_for(choice_hash) # rubocop:disable Style/StringConcatenation
            else
              render_body_for choice_hash
            end
          end
        end

        def render_body_for(choice_hash)
          return choice_hash[:response_option_body] if choice_hash[:choice_body].blank?

          "#{choice_hash[:response_option_body]} (#{choice_hash[:choice_body]})"
        end

        def body_or_custom_body(choice)
          return choice.custom_body if choice.try(:custom_body).present?

          ""
        end
      end
    end
  end
end
