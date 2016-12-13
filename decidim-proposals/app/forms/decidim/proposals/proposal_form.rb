module Decidim
  module Proposals
    class ProposalForm < Decidim::Form
      mimic :proposal

      attribute :title, String
      attribute :body, String
      attribute :author, Decidim::User
      attribute :category_id, Integer
      attribute :scope, Decidim::Scope
      attribute :feature, Decidim::Feature

      validates :title, :body, :author, :feature, presence: true
      validates :category, presence: true, if: lambda { |form| form.category_id.present? }

      def category
        @category ||= feature.categories.where(id: category_id).first
      end
    end
  end
end
