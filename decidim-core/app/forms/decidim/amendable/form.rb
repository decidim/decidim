# frozen_string_literal: true

module Decidim
  module Amendable
    # a form object common for amendments
    class Form < Decidim::Form
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

      def check_amendable_form_validations
        parse_hashtaggable_params
        return if amendable_form.valid?

        @errors = @amendable_form.errors
      end

      def amendable_form
        @amendable_form = amendable
                          .amendable_form
                          .from_params(emendation_params)
                          .with_context(current_component: amendable.component,
                                        current_participatory_space: amendable.participatory_space)
      end

      def parse_hashtaggable_params
        emendation_params.each do |key, value|
          next unless [:title, :body].include?(key)
          emendation_params[key] = Decidim::ContentProcessor
                                   .parse_with_processor(
                                     :hashtag,
                                     value,
                                     current_organization: amendable.organization
                                   ).rewrite
        end
      end
    end
  end
end
