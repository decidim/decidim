# frozen_string_literal: true

module Decidim
  module Registrations
    class UserAttributeValidator
      def initialize(attribute:, form:, model_class: nil)
        @attribute = attribute
        @form = form
        @model_class = model_class.presence || "Decidim::#{@form.model_name.human}".constantize
        @errors = ["Invalid attribute"] unless valid_attribute?(attribute)
      end

      delegate :current_organization, to: :form
      attr_reader :attribute
      attr_accessor :model_class, :form

      def valid?
        @valid ||= begin
          form.validate
          # we don't validate the form but the attribute alone
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
        return error unless suggestion.present?

        "#{error}. Try #{suggestion}" unless valid? # TODO: i18n
      end

      def suggestion
        @suggestion ||= begin
          word = input
          loop do
            break unless valid_suggestor?(attribute)
            break unless model_class.exists?(organization: current_organization, attribute => word)

            # reuse and increment a last number if exists
            word.gsub!(/([^\d.]+)(\d*)/) { "#{$1}#{$2.to_i + 1}" }
          end
          word
        end
      end

      def valid_attribute?(key)
        ["nickname", "email", "name", "password"].include? key.to_s
      end

      def valid_suggestor?(key)
        ["nickname"].include? key.to_s
      end
    end
  end
end
