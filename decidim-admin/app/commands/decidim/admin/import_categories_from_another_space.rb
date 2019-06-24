# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when an admin imports categories from
    # one space to another.
    class ImportCategoriesFromAnotherSpace < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @form.valid?

        broadcast(:ok, create_categories)
      end

      private

      attr_reader :form

      def create_categories
        transaction do
          parent_categories(origin_participatory_space).map do |original_parent_category|
            new_parent_category = create_category(original_parent_category)
            sub_categories(original_parent_category).map do |original_sub_category|
              create_category(original_sub_category, new_parent_category)
            end.compact
          end.compact
        end
      end

      def create_category(original_category, parent_category = nil)
        category = Decidim::Category.new
        category.participatory_space = current_participatory_space
        category.name = original_category.name
        category.description = original_category.description
        category.parent = parent_category
        category.save!
        return category
      end

      def categories(space)
        Decidim::Category.where(participatory_space: space)
      end

      def parent_categories(space)
        categories(space).where(parent: nil)
      end

      def sub_categories(parent_category)
        categories(parent_category.participatory_space).where(parent: parent_category)
      end

      def origin_participatory_space
        @form.origin_participatory_space
      end

      def current_participatory_space
        @form.current_participatory_space
      end
    end
  end
end
