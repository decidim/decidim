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

    validates :organization, :user, :action, :resource, presence: true

    # Renders the action log instance. Assumes the existence of the presenter
    # class for the related `resource`, which will be in charge of the actual
    # rendering of the data.
    #
    # The presenter class name is built from the resource class name and module:
    # If the associated resource class name is this:
    #
    #     Decidim::MyModule::MyModel
    #
    # Then the presenter class that will be required is
    #
    #     Decidim::MyModule::ActionLog::MyModelPresenter
    #
    # We attach the `AdminLog` module to the presenter class name to differentiate
    # between log types. This way we can have different logs, with different
    # presentations, with the same data. We currently assume only one log is present
    # (`AdminLog`), but we have a structure that enables multiple logs in the future.
    #
    # view_helpers - an object that holds all the view helpers accessible at the render
    #   time.
    #
    # Returns an HTML-safe String.
    def render_log(view_helpers)
      presenter_klass_name = resource_type.deconstantize
      presenter_klass_name << "::AdminLog::"
      presenter_klass_name << resource_type.demodulize
      presenter_klass_name << "Presenter"
      presenter_klass_name.constantize.new(self, view_helpers).render
    end
  end
end
