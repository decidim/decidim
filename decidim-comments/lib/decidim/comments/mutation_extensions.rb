# frozen_string_literal: true

module Decidim
  module Comments
    # This module's job is to extend the API with custom fields related to
    # decidim-comments.
    module MutationExtensions
      # Public: Extends a type with `decidim-comments`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(type)
        type.field :commentable, Decidim::Comments::CommentableMutationType, null: false do
          description "A commentable"

          argument :id, GraphQL::Types::String, "The commentable's ID", required: true
          argument :type, GraphQL::Types::String, "The commentable's class name. i.e. `Decidim::ParticipatoryProcess`", required: true
          argument :locale, GraphQL::Types::String, "The locale for which to get the comments text", required: false
          argument :toggle_translations, GraphQL::Types::Boolean, "Whether the user asked to toggle the machine translations or not.", required: false
        end

        type.field :comment, Decidim::Comments::CommentMutationType, null: false do
          description "A comment"

          argument :id, GraphQL::Types::ID, "The comment's id", required: true
          argument :locale, GraphQL::Types::String, "The locale for which to get the comments text", required: false
          argument :toggle_translations, GraphQL::Types::Boolean, "Whether the user asked to toggle the machine translations or not.", required: false
        end
      end

      def commentable(id:, type:, locale: Decidim.default_locale, toggle_translations: false)
        I18n.locale = locale.presence
        RequestStore.store[:toggle_machine_translations] = toggle_translations
        type.constantize.find(id)
      end

      def comment(id:, locale: Decidim.default_locale, toggle_translations: false)
        I18n.locale = locale.presence
        RequestStore.store[:toggle_machine_translations] = toggle_translations
        Comment.find(id)
      end
    end
  end
end
