# frozen_string_literal: true

module Decidim
  module Accountability
    class DeleteResultType < Api::SoftDeleteResourceType
      description "deletes a result"

      type Decidim::Accountability::ResultType

      def authorized?(id:)
        result = find_resource(id)
        context[:trashable_deleted_resource] = result

        super && allowed_to?(:soft_delete, :result, result, context, scope: :admin)
      end

      private

      def find_resource(id)
        Decidim::Accountability::Result.find_by(id:, component: object)
      end

      def trashable_deleted_resource_type
        :result
      end
    end
  end
end
