module Decidim
  # This module's job is to extend the API with custom fields related to
  # decidim-core.
  module QueryExtensions
    # Public: Extends a type with `decidim-core`'s fields.
    #
    # type - A GraphQL::BaseType to extend.
    #
    # Returns nothing.
    def self.extend!(type)
      type.define do
        field :processes do
          type !types[ProcessType]
          description "Lists all processes."

          resolve ->(_obj, _args, ctx) {
            OrganizationParticipatoryProcesses.new(ctx[:current_organization])
          }
        end
      end
    end
  end
end
