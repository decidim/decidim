# frozen_string_literal: true
module Decidim
  module Budgets
    # The data store for a Project in the Decidim::Budgets component. It stores a
    # title, description and any other useful information to render a custom project.
    class Project < Budgets::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasFeature
      include Decidim::HasScope
      include Decidim::HasCategory
      include Decidim::HasAttachments

      feature_manifest_name "budgets"
    end
  end
end
