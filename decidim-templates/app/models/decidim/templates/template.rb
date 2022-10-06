# frozen_string_literal: true

# Templates can be defined from the admin panel to store and use objects
# with given values and use them to create new ones using these values as default
#
# The model class we want to create these templates from must include the Templatable
# concern. A controller should be created to manage templates for the model,
# as well as the routes for the controller actions. The command classes to use in
# these actions should also be created to define the particular data management
# for the model's templates.
module Decidim
  module Templates
    class Template < ApplicationRecord
      include Decidim::Traceable

      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"

      belongs_to :templatable, foreign_type: "templatable_type", polymorphic: true, optional: true

      before_destroy :destroy_templatable

      validates :name, presence: true

      def resource_name
        [templatable_type.demodulize.tableize.singularize, "templates"].join("_")
      end

      def destroy_templatable
        templatable.destroy
      end

      def self.log_presenter_class_for(_log)
        Decidim::Templates::AdminLog::TemplatePresenter
      end
    end
  end
end
