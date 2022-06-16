# frozen_string_literal: true

module Decidim
  module Registrations
    class UserAttributeValidator
      def initialize(attribute: "", suggest: "", form: Decidim::RegistrationForm)
        @attribute = attribute
        @suggest = suggest
        @form = form
        @model = "Decidim::#{form.model_name.human}".constantize
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

            @suggestion = "#{@suggestion}1"
          end
          @suggestion
        end
      end

      def valid_suggestor?(attribute)
        [:nickname].with_indifferent_access.include? attribute
      end
    end
  end
end
