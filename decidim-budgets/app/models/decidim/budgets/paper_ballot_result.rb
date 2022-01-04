module Decidim
  module Budgets
    # The data store for a PaperBallotResult in the Budget resource.
    class PaperBallotResult < Budgets::ApplicationRecord
      belongs_to :project, class_name: "Decidim::Budgets::Project", foreign_key: "decidim_project_id"
    end
  end
end
