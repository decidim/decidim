# frozen_string_literal: true

module Decidim
  # This class represents an action of a user on a resource. It is used
  # for transparency reasons, to log all actions so all other users can
  # see the actions being performed.
  class ActionLog < ApplicationRecord
    belongs_to :organization,
               foreign_key: :decidim_organization_id,
               class_name: "Decidim::Organization"

    belongs_to :user,
               foreign_key: :decidim_user_id,
               class_name: "Decidim::User"

    belongs_to :feature,
               foreign_key: :decidim_feature_id,
               optional: true,
               class_name: "Decidim::Feature"

    belongs_to :resource,
               polymorphic: true

    belongs_to :participatory_space,
               optional: true,
               polymorphic: true

    belongs_to :version,
               optional: true,
               class_name: "PaperTrail::Version"

    validates :organization, :user, :action, :resource, presence: true

    # To ensure records can't be deleted
    before_destroy { |_record| raise ActiveRecord::ReadOnlyRecord }

    # Overwrites the method so that records cannot be modified.
    #
    # Returns a Boolean.
    def readonly?
      !new_record?
    end

    # Public: Finds the correct presenter class for the given
    # `log_type` and the related `resource_type`. If no specific
    # presenter can be found, it falls back to `Decidim::Log::BasePresenter`
    #
    # log_type - a Symbol representing the log
    #
    # Returns a Class.
    def log_presenter_class_for(log_type)
      resource_type.constantize.log_presenter_class_for(log_type)
    rescue NameError
      Decidim::Log::BasePresenter
    end
  end
end
