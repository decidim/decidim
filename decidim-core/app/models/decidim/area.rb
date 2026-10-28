# frozen_string_literal: true

module Decidim
  # Areas are used in Assemblies to help users know which is
  # the Area of a participatory space.
  class Area < ApplicationRecord
    include Traceable
    include Loggable
    include Decidim::TranslatableResource

    translatable_fields :name

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization",
               inverse_of: :areas

    belongs_to :area_type,
               class_name: "Decidim::AreaType",
               inverse_of: :areas,
               optional: true

    # Reciprocal of the models that point to an area. `Decidim::ActionLog` records cannot be
    # destroyed (see the `before_destroy` callback on that model), so this cascade uses `delete_all`.
    has_many :action_logs,
             foreign_key: "decidim_area_id",
             class_name: "Decidim::ActionLog",
             inverse_of: :area,
             dependent: :delete_all

    validates :name, presence: true, uniqueness: { scope: [:organization, :area_type] }

    before_destroy :abort_if_dependencies

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::AreaPresenter
    end

    def translated_name
      Decidim::AreaPresenter.new(self).translated_name
    end

    def has_dependencies?
      Decidim.participatory_space_registry.manifests.any? do |manifest|
        manifest
          .participatory_spaces
          .call(organization)
          .any? do |space|
          space.respond_to?(:area) && space.decidim_area_id == id
        end
      end
    end

    # used on before_destroy
    def abort_if_dependencies
      throw(:abort) if has_dependencies?
    end
  end
end
