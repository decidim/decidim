# frozen_string_literal: true

module Decidim
  module Dev
    module Admin
      # A form object for the dummy component. Used to validate what happens
      # when there are errors on the form.
      #
      class DummyComponentForm < Decidim::Admin::ComponentForm
        mimic :component

        validate :dummy_setting

        private

        def dummy_setting
          return unless manifest&.name == :dummy

          invalid_number = settings.error_honeypot_number.blank? || (settings.error_honeypot_number.to_i != 0)
          settings.errors.add(:error_honeypot_number) if invalid_number
        end
      end
    end
  end
end
