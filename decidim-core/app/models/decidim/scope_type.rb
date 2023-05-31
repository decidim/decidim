# frozen_string_literal: true

module Decidim
  # Scope types allows to use different types of scopes in participatory process
  # (municipalities, provinces, states, countries, etc.)
  class ScopeType < ApplicationRecord
    include Decidim::TranslatableResource
    include Traceable

    translatable_fields :name, :plural
    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization",
               inverse_of: :scope_types

    has_many :scopes, class_name: "Decidim::Scope", inverse_of: :scope_type, dependent: :nullify

    validates :name, presence: true

    before_destroy :detach_dynamic_associations

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::ScopeTypePresenter
    end

    private

    # This method detaches all records that may have association with the scope
    # type. This cannot be done directly using the `dependent` option in the
    # `has_many` relation in order to avoid tight coupling between the modules.
    #
    # This logic does not have to be applied to any classes that have been
    # defined as `has_many` associations within this model already as they are
    # already handled by the `dependent` option.
    def detach_dynamic_associations
      ActiveRecord::Base.descendants.each do |cls|
        next if cls.abstract_class? || !cls.name&.match?(/^Decidim::/)
        next if cls == self.class || cls == Decidim::Scope

        cls.reflect_on_all_associations(:belongs_to).each do |ref|
          next unless ref.options[:class_name] == self.class.name

          cls.where(ref.options[:foreign_key] => id).update_all(ref.options[:foreign_key] => nil) # rubocop:disable Rails/SkipsModelValidations
        end
      end
    end
  end
end
