# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      #
      # Presenter for questionnaire answer
      #
      class QuestionnaireAnswerPresenter < Rectify::Presenter
        include Decidim::TranslatableAttributes

        attribute :answer, Decidim::Forms::Answer

        def question
          translated_attribute(answer.question.body)
        end

        def body
          return answer.body if answer.body.present?
          return attachments if answer.attachments.any?
          return "-" if answer.choices.empty?

          choices = answer.choices.map do |choice|
            choice.try(:custom_body) || choice.try(:body)
          end

          return choices.first if answer.question.question_type == "single_option"

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
            link_to(translated_attribute(attachment.title), attachment.url) +
              " " +
              content_tag(:small) do
                "#{attachment.file_type} #{number_to_human_size(attachment.file_size)}"
              end
          end
          # rubocop:enable Style/StringConcatenation
        end

        def choice(choice_body)
          content_tag :li do
            choice_body
          end
        end
      end
    end
  end
end
