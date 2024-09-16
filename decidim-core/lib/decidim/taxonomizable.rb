# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to have taxonomies.
  #
  # The including model needs to implement the following interface:
  #
  #  @abstract  method that gives an associated organization
  #  @method organization
  #    @return [Decidim::Organization]
  #
  module Taxonomizable
    extend ActiveSupport::Concern

    included do
      has_many :taxonomizations, as: :taxonomizable, class_name: "Decidim::Taxonomization", dependent: :destroy
      has_many :taxonomies, through: :taxonomizations

      validate :no_root_taxonomies
      validate :taxonomies_belong_to_organization

      private

      def no_root_taxonomies
        return unless taxonomies.any?(&:root?)

        errors.add(:taxonomies, :invalid)
      end

      def taxonomies_belong_to_organization
        return if taxonomies.all? { |taxonomy| taxonomy.organization == organization }

        errors.add(:taxonomies, :invalid)
      end
    end
  end
end
