# frozen_string_literal: true
module Decidim
  module Proposals
    # The data store for a Proposal in the Decidim::Proposals component.
    class Proposal < Proposals::ApplicationRecord
      validates :title, :feature, :body, presence: true
      belongs_to :feature, foreign_key: "decidim_feature_id", class_name: Decidim::Feature
      belongs_to :author, foreign_key: "decidim_author_id", class_name: Decidim::User
      belongs_to :category, foreign_key: "decidim_category_id", class_name: Decidim::Category
      belongs_to :scope, foreign_key: "decidim_scope_id", class_name: Decidim::Scope

      # TODO
      # Validate categories belong to the process
      # Validate scopes belong to the process
    end
  end
end
