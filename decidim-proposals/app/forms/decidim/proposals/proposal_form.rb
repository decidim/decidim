module Decidim
  module Proposals
    class ProposalForm < Decidim::Form
      mimic :proposal

      attribute :title, String
      attribute :body, String
      attribute :author, Decidim::User
      attribute :category, Decidim::Category
      attribute :category_id, Integer
      attribute :scope, Decidim::Scope

      validates :title, :body, :author, presence: true
    end
  end
end
