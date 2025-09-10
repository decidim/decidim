# frozen_string_literal: true

module Decidim
  # This module's job is to extend the API with custom fields related to
  # decidim-core.
  module QueryExtensions
    # Public: Extends a type with `decidim-core`'s fields.
    #
    # type - A GraphQL::BaseType to extend.
    #
    # Returns nothing.
    def self.included(type)
      type.field :component, Decidim::Core::ComponentInterface, null: true do
        description "Lists the components this space contains."
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the component to be found"
      end

      type.field :session, Core::SessionType, description: "Return's information about the logged in user", null: true

      type.field :decidim, Core::DecidimType, "Decidim's framework properties.", null: true

      type.field :organization, Core::OrganizationType, "The current organization", null: true

      type.field :user,
                 type: Core::AuthorInterface, null: true,
                 description: "A participant (user or group) in the current organization" do
        argument :id, GraphQL::Types::ID, "The ID of the participant", required: false
        argument :nickname, GraphQL::Types::String, "The @nickname of the participant", required: false
      end

      type.field :users,
                 type: [Core::AuthorInterface], null: true,
                 description: "The participants (users or groups) for the current organization" do
        argument :order, Decidim::Core::UserEntityInputSort, "Provides several methods to order the results", required: false
        argument :filter, Decidim::Core::UserEntityInputFilter, "Provides several methods to filter the results", required: false
      end
    end

    def component(id: {})
      component = Decidim::Component.published.find_by(id:)
      component&.organization == context[:current_organization] ? component : nil
    end

    def session
      context[:current_user]
    end

    def decidim
      Decidim
    end

    def organization
      context[:current_organization]
    end

    def user(id: nil, nickname: nil)
      Core::UserEntityFinder.new.call(object, { id:, nickname: }, context)
    end

    def users(filter: {}, order: {})
      Core::UserEntityList.new.call(object, { filter:, order: }, context)
    end
  end
end
