# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes TemplateTexts from the admin
      # panel.
      class UpdateTemplateTexts < Rectify::Command
        # Initializes an UpdateResult Command.
        #
        # form - The form from which to get the data.
        # template_texts - The current instance of the template_texts to be updated.
        def initialize(form, template_texts)
          @form = form
          @template_texts = template_texts
        end

        # Updates the result if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_template_texts
          end

          broadcast(:ok)
        end

        private

        attr_reader :template_texts, :form

        def update_template_texts
          template_texts.update_attributes!(
            intro: @form.intro,
            categories_label: @form.categories_label,
            subcategories_label: @form.subcategories_label,
            heading_parent_level_results: @form.heading_parent_level_results,
            heading_leaf_level_results: @form.heading_leaf_level_results,
          )
        end
      end
    end
  end
end
