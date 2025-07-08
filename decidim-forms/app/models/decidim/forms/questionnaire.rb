# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a Questionnaire in the Decidim::Forms component.
    class Questionnaire < Forms::ApplicationRecord
      include Decidim::Templates::Templatable if defined? Decidim::Templates::Templatable
      include Decidim::Publicable
      include Decidim::TranslatableResource
      include Decidim::Traceable

      translatable_fields :title, :description, :tos
      belongs_to :questionnaire_for, polymorphic: true

      has_many :questions, -> { order(:position) }, class_name: "Question", foreign_key: "decidim_questionnaire_id", dependent: :destroy
      has_many :responses, class_name: "Response", foreign_key: "decidim_questionnaire_id", dependent: :destroy

      after_initialize :set_default_salt

      attr_accessor :questionnaire_template_id
      attr_reader :override_edit

      # Public: returns whether the questionnaire questions can be modified or not.
      def questions_editable?
        has_component = questionnaire_for.respond_to? :component
        (has_component && !questionnaire_for.component.published?) || override_edit.presence || responses.empty?
      end

      def override_edit!
        @override_edit = true
      end

      # Public: returns whether the questionnaire is responded by the user or not.
      def responded_by?(user)
        query = user.is_a?(String) ? { session_token: user } : { user: }
        responses.where(query).any? if questions.present?
      end

      def pristine?
        created_at.to_i == updated_at.to_i && questions.empty?
      end

      def self.log_presenter_class_for(_log)
        Decidim::Forms::AdminLog::QuestionnairePresenter
      end

      def count_participants
        Decidim::Forms::QuestionnaireParticipants.new(self).count_participants
      end

      private

      # salt is used to generate secure hash in anonymous responses
      def set_default_salt
        return unless defined?(salt)

        self.salt ||= Tokenizer.random_salt
      end
    end
  end
end
