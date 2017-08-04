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
    def self.extend!(type)
      type.define do
        field :processes do
          type !types[ProcessType]
          description "Lists all processes."

          resolve lambda { |_obj, _args, ctx|
            ParticipatoryProcesses::OrganizationPublishedParticipatoryProcesses.new(ctx[:current_organization])
          }
        end

        field :session do
          type SessionType
          description "Return's information about the logged in user"

          resolve lambda { |_obj, _args, ctx|
            ctx[:current_user]
          }
        end

        field :decidim, DecidimType, "Decidim's framework properties." do
          resolve ->(_obj, _args, _ctx) { Decidim }
        end
      end
    end
  end
end
