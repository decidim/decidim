# frozen_string_literal: true

module Decidim
  module Amendable
    # a form object common for amendments
    class Form < Decidim::Form
      include Decidim::TranslatableAttributes

      mimic :amendment

      def amendment
        @amendment ||= Decidim::Amendment.find_by(id: id)
      end

      def amendable
        @amendable ||= amendment&.amendable
      end

      def emendation
        @emendation ||= amendment&.emendation
      end

      def amender
        @amender ||= amendment&.amender
      end

      private

      # Validates the emendation is not identical to the amendable.
      def emendation_must_change_amendable
        return unless %w(title body).all? { |attr| attr.in? amendable_fields_as_string }

        emendation = amendable.class.new(emendation_params)
        return unless translated_attribute(amendable.title) == emendation.title
        return unless normalized_body(amendable) == normalized_body(emendation)

        amendable_form.errors.add(:title, :identical)
        amendable_form.errors.add(:body, :identical)
      end

      # Normalizes the escape sequences used for newlines.
      def normalized_body(resource)
        body = translated_attribute(resource.body)
        Decidim::ContentParsers::NewlineParser.new(body, context: {}).rewrite
      end

      # Validates the emendation using the amendable form.
      def amendable_form_must_be_valid
        parse_hashtaggable_params

        original_form.validate unless defined?(@amendable_form)
        amendable_form.validate unless defined?(@amendable_form)
        errors = flatten_errors(amendable_form.errors.details) - flatten_errors(original_form.errors.details)
        @amendable_form.errors.clear
        add_errors(errors)

        @errors = amendable_form.errors
      end

      def flatten_errors(form_errors)
        form_errors.flat_map do |attribute, errors|
          errors.map do |error|
            error.flat_map { |_, value| [attribute, value] }
          end
        end
      end

      def add_errors(errors)
        errors.each do |attribute, error|
          next if amendable_form.errors.details[attribute].include? error: error

          amendable_form.errors.add(attribute, error)
        end
      end

      # Parses :title and :body attribute values with HashtagParser.
      def parse_hashtaggable_params
        emendation_params.each do |key, value|
          next unless [:title, :body].include?(key)

          clean_value = translated_attribute(value)
          emendation_params[key] = Decidim::ContentParsers::HashtagParser.new(clean_value, form_context).rewrite
        end
      end

      def original_form
        @original_form ||= amendable
                           .amendable_form
                           .from_model(amendable)
                           .with_context(
                             current_component: amendable.component,
                             current_participatory_space: amendable.participatory_space
                           )
      end

      # Returns an instance of the Form Object class defined in Decidim::Amendable#amendable_form
      # constructed with the :emendation_params.
      def amendable_form
        @amendable_form ||= amendable.amendable_form.from_params(emendation_params).with_context(form_context)
      end

      # Returns the amendable fields keys as String.
      def amendable_fields_as_string
        amendable.amendable_fields.map(&:to_s)
      end

      # Adds additional information to the base context from the current controller.
      def form_context
        context.to_h.merge(
          current_component: amendable.component,
          current_participatory_space: amendable.participatory_space
        )
      end
    end
  end
end
