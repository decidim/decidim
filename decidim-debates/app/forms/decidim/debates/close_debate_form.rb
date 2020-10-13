# frozen_string_literal: true

module Decidim
  module Debates
    # This class holds a Form to close debates from Decidim's public views.
    class CloseDebateForm < Decidim::Form
      mimic :debate

      attribute :conclusions, String
      attribute :debate, Debate

      validates :debate, presence: true
      validates :conclusions, presence: true, length: { minimum: 10, maximum: 10_000 }
      validate :user_can_close_debate

      def closed_at
        debate&.closed_at || Time.current
      end

      def map_model(debate)
        super
        self.debate = debate

        # Debates can be translated in different languages from the admin but
        # the public form doesn't allow it. When a user closes a debate the
        # user locale is taken as the text locale.
        self.conclusions = debate.conclusions&.values&.first
      end

      private

      def user_can_close_debate
        return if !debate || !debate.respond_to?(:closeable_by?)

        errors.add(:debate, :invalid) unless debate.closeable_by?(current_user)
      end
    end
  end
end
