# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      #
      # Presenter for questionnaire answer
      #
      class QuestionnaireAnswerPresenter < SimpleDelegator
        delegate :content_tag, :safe_join, :link_to, :number_to_human_size, to: :view_context

        include Decidim::TranslatableAttributes

        def answer
          __getobj__.fetch(:answer)
        end

        def view_context
          __getobj__.fetch(:view_context, ActionController::Base.new.view_context)
        end

        def question
          translated_attribute(answer.question.body)
        end

        def body
          return answer.body if answer.body.present?
          return attachments if answer.attachments.any?
          return "-" if answer.choices.empty?

          choices = answer.choices.map do |choice|
            {
              answer_option_body: choice.try(:answer_option).try(:translated_body),
              choice_body: body_or_custom_body(choice)
            }
          end

          return choice(choices.first) if answer.question.question_type == "single_option"

          content_tag(:ul) do
            safe_join(choices.map { |c| choice(c) })
          end
        end

        def attachments
          content_tag(:ul) do
            safe_join(answer.attachments.map { |a| pretty_attachment(a) })
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
                  I18n.t("download_attachment", scope: "decidim.forms.questionnaire_answer_presenter")
              end + " " + content_tag(:small) do
                "#{attachment.file_type} #{number_to_human_size(attachment.file_size)}"
              end
            end
          end
          # rubocop:enable Style/StringConcatenation
        end

        def choice(choice_hash)
          content_tag :li do
            render_body_for choice_hash
          end
        end

        def render_body_for(choice_hash)
          return choice_hash[:answer_option_body] if choice_hash[:choice_body].blank?

          "#{choice_hash[:answer_option_body]} (#{choice_hash[:choice_body]})"
        end

        def body_or_custom_body(choice)
          return choice.custom_body if choice.try(:custom_body).present?

          ""
        end
      end
    end
  end
end
