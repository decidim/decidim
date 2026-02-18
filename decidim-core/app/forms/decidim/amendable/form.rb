# frozen_string_literal: true

module Decidim
  module Amendable
    # a form object common for amendments
    class Form < Decidim::Form
      include Decidim::TranslatableAttributes

      mimic :amendment

      def amendment
        @amendment ||= Decidim::Amendment.find_by(id:)
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
        parse_content_params
        original_form.validate unless defined?(@original_form) # Preserves previously added errors.

        amendable_form.validate unless defined?(@amendable_form) # Preserves previously added errors.

        compare_amendable_form_errors(@amendable_form.errors.dup) if @original_form.present? && @original_form.errors.details.count.positive?

        @errors = @amendable_form.errors
      end

      # Compare the amendable_form errors and original_form errors
      # If amendable_form add more errors than original, error is stored in amendable_form errors.
      #
      # Params: amendable_form_errors => Duplicated @amendable_form.errors
      def compare_amendable_form_errors(amendable_form_errors)
        @amendable_form.errors.clear
        @original_form.errors.details.keys.each do |key|
          errors = amendable_form_errors.details[key] - @original_form.errors.details[key]

          errors.map do |hash|
            error = hash.delete(:error)
            @amendable_form.errors.add(key, error, **hash) unless @amendable_form.errors.details[key].include?(error:)
          end
        end
      end

      # Parses :title and :body attribute values with BlobParser.
      def parse_content_params
        emendation_params.each do |key, value|
          next unless [:title, :body].include?(key)

          clean_value = translated_attribute(value)
          emendation_params[key] = Decidim::ContentParsers::BlobParser.new(clean_value, form_context).rewrite
        end
      end

      # Returns an instance of the Form Object class defined in Decidim::Amendable#amendable_form
      # constructed with the :emendation_params.
      def amendable_form
        @amendable_form ||= amendable.amendable_form.from_params(emendation_params).with_context(form_context)
      end

      def original_form
        @original_form ||= i18n_amendable
                           .amendable_form
                           .from_model(@i18n_amendable)
                           .with_context(
                             current_component: @i18n_amendable.component,
                             current_participatory_space: @i18n_amendable.participatory_space,
                             current_organization: @i18n_amendable.organization
                           )
      end

      def i18n_amendable
        @i18n_amendable ||= amendable
        @i18n_amendable.title = translated_attribute(amendable.title)
        @i18n_amendable.body = normalized_body(amendable)
        @i18n_amendable
      end

      # Returns the amendable fields keys as String.
      def amendable_fields_as_string
        amendable.amendable_fields.map(&:to_s)
      end

      # Adds additional information to the base context from the current controller.
      def form_context
        context.to_h.merge(
          current_component: amendable.component,
          current_participatory_space: amendable.participatory_space,
          current_organization: amendable.organization
        )
      end
    end
  end
end
