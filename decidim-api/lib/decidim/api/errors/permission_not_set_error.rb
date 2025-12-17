# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      class PermissionNotSetError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "NO_PERMISSION_SET" } })
        end
      end
    end
  end
end
