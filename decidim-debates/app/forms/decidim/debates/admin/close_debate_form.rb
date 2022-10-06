# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This class holds a Form to close debates from Decidim's admin views.
      class CloseDebateForm < Decidim::Form
        include TranslatableAttributes

        mimic :debate

        translatable_attribute :conclusions, Decidim::Attributes::CleanString do |translated_attribute, locale|
          validates translated_attribute, presence: true, if: ->(record) { record.default_locale?(locale) }
          validates translated_attribute, length: { minimum: 10, maximum: 10_000 }, if: ->(record) { record.default_locale?(locale) }
        end

        validates :debate, presence: true
        validate :user_can_close_debate

        def closed_at
          debate&.closed_at || Time.current
        end

        def debate
          @debate ||= Debate.find_by(id:)
        end

        private

        def user_can_close_debate
          errors.add(:debate, :invalid) unless debate.official?
        end
      end
    end
  end
end
