# frozen_string_literal: true

module Decidim
  module Core
    class UserEntityInputFilter < BaseInputFilter
      graphql_name "UserEntityFilter"
      description "A type used for filtering any user or group

      A typical query would look like:

      ```
      {
        users(filter:{wildcard:\"sandy\", excludeIds:[2,10,11]}) {
          id
          ...on User {
            groups {
              name
            }
          }
          ...on UserGroup {
            members {
              name
            }
          }
        }
      }
      ```
      "

      argument :type, type: String, description: "Filters by type of entity (User or UserGroup)", required: false, prepare: ->(value, _ctx) do
                                                                                                                              type = value.downcase.camelcase
                                                                                                                              if %w(Group Usergroup).include?(type)
                                                                                                                                type = "UserGroup"
                                                                                                                              end
                                                                                                                              { type: "Decidim::#{type}" }
                                                                                                                            end
      argument :name,
               type: String,
               description: "Filters by name of the user entity. Searches (case insensitive) any fragment of the provided string",
               required: false,
               prepare: ->(value, _ctx) do
                 [lambda { |model_class, _locale| model_class.arel_table[:name].matches("%#{value}%") }]
               end
      argument :nickname,
               type: String,
               description: "Filters by nickname of the user entity. Searches (case insensitive) any fragment of the provided string",
               required: false, prepare: ->(value, _ctx) do
                                           value = value[1..-1] if value.starts_with? "@"
                                           [lambda { |model_class, _locale| model_class.arel_table[:nickname].matches("%#{value}%") }]
                                         end
      argument :wildcard,
               type: String,
               description: "Filters by nickname or name of the user entity. Searches (case insensitive) any fragment of the provided string",
               required: false, prepare: ->(value, _ctx) do
                                           value = value[1..-1] if value.starts_with? "@"
                                           [
                                             lambda { |model_class, _locale|
                                               op_name = model_class.arel_table[:name].matches("%#{value}%")
                                               op_nick = model_class.arel_table[:nickname].matches("%#{value}%")
                                               op_name.or(op_nick)
                                             }
                                           ]
                                         end
      argument :exclude_ids, type: [ID],
                             description: "Excludes users contained in given ids. Valid values are one or more IDs (passed as an array)",
                             required: false,
                             prepare: ->(value, _ctx) do
                                        [lambda { |model_class, _locale| model_class.arel_table[:id].not_in(value) }]
                                      end
    end
  end
end
