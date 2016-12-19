# frozen_string_literal: true
module Decidim
  module Meetings
    # The data store for a Meeting in the Decidim::Meetings component. It stores a
    # title, description and any other useful information to render a custom meeting.
    class Meeting < Meetings::ApplicationRecord
      belongs_to :feature, foreign_key: "decidim_feature_id", class_name: Decidim::Feature
      belongs_to :scope, foreign_key: "decidim_scope_id", class_name: Decidim::Scope

      validates :title, presence: true

      validate :scope_belongs_to_organization

      private

      def scope_belongs_to_organization
        return unless scope
        errors.add(:scope, :invalid) unless feature.scopes.where(id: scope.id).exists?
      end
    end
  end
end
