# frozen_string_literal: true

module Decidim
  module Registrations
    class UserAttributeValidator
      def initialize(attribute: "", form: nil, model: nil)
        @attribute = attribute
        @form = form.presence || Decidim::RegistrationForm
        @model = model.presence || "Decidim::#{form.model_name.human}".constantize
      end

      delegate :current_organization, to: :form
      attr_reader :attribute
      attr_accessor :model, :form

      def valid?
        @valid ||= begin
          form.validate
          errors.blank?
        end
      end

      def input
        @input ||= form.public_send(attribute)
      end

      def errors
        @errors ||= form.errors[attribute]
      end

      def error
        errors.flatten.join(". ") unless valid?
      end

      def error_with_suggestion
        "#{error}. Try #{suggestion}" unless valid? # TODO: i18n
      end

      def suggestion
        @suggestion ||= begin
          @suggestion = input
          loop do
            break unless valid_suggestor?(attribute)
            break unless model.exists?(organization: current_organization, attribute => @suggestion)

            @suggestion.gsub!(/([^\d.]+)(\d*)/) { "#{$1}#{$2.to_i + 1}" }
          end
          @suggestion
        end
      end

      def valid_suggestor?(key)
        ["nickname"].include? key.to_s
      end
    end
  end
end
