# frozen_string_literal: true

module Decidim
  module Registrations
    class UserAttributeValidator
      def initialize(attribute: "", suggest: "", form: nil, model: nil)
        @attribute = attribute
        @suggest = suggest
        @form = form.presence || Decidim::RegistrationForm
        @model = model.presence || "Decidim::#{form.model_name.human}".constantize
      end

      delegate :current_organization, to: :form
      attr_reader :attribute, :suggest
      attr_accessor :model, :form

      def valid?
        form.validate
        form.errors[attribute].blank?
      end

      def input
        form.public_send(attribute)
      end

      def error
        form.errors[attribute].flatten.join(". ") unless valid?
      end

      def suggestion
        @suggestion ||= begin
          @suggestion = input
          loop do
            break unless valid_suggestor?(suggest)
            break unless model.exists?(organization: current_organization, suggest => @suggestion)

            @suggestion.gsub!(/([^\d.]+)(\d*)/) { "#{$1}#{$2.to_i + 1}" }
          end
          @suggestion
        end
      end

      def valid_suggestor?(attribute)
        ["nickname"].include? attribute.to_s
      end
    end
  end
end
