# frozen_string_literal: true

module Decidim
  module Amendable
    # a form object common for amendments
    class Form < Decidim::Form
      include Decidim::ApplicationHelper

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

      def amendable_fields_as_string
        amendable.amendable_fields.map(&:to_s)
      end

      def emendation_changes_amendable
        return unless %w(title body).all? { |attr| attr.in? amendable_fields_as_string }

        emendation = amendable.amendable_type.constantize.new(emendation_params)
        return unless present(amendable).title == present(emendation).title
        return unless present(amendable).body.strip == present(emendation).body.strip

        amendable_form.errors.add(:title, :identical)
        amendable_form.errors.add(:body, :identical)
      end

      def check_amendable_form_validations
        parse_hashtaggable_params
        # Preserves the errors added in #emendation_changes_amendable.
        amendable_form.validate unless defined?(@amendable_form)
        @errors = @amendable_form.errors
      end

      def parse_hashtaggable_params
        emendation_params.each do |key, value|
          next unless [:title, :body].include?(key)

          emendation_params[key] = Decidim::ContentParsers::HashtagParser.new(value, form_context).rewrite
        end
      end

      def amendable_form
        @amendable_form ||= amendable.amendable_form.from_params(emendation_params).with_context(form_context)
      end

      def form_context
        context.to_h.merge(
          current_component: amendable.component,
          current_participatory_space: amendable.participatory_space
        )
      end
    end
  end
end
