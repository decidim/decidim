# frozen_string_literal: true

module Decidim
  module Votings
    class Voting < ApplicationRecord
      include Traceable
      include Loggable
      include Decidim::Participable
      include Decidim::ParticipatorySpaceResourceable
      include Decidim::Searchable
      include Decidim::TranslatableResource
      include Decidim::ScopableParticipatorySpace
      include Decidim::Publicable

      translatable_fields :title, :description

      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"

      validates :slug, uniqueness: { scope: :organization }
      validates :slug, presence: true, format: { with: Decidim::Votings::Voting.slug_format }

      searchable_fields({
                          scope_id: :decidim_scope_id,
                          participatory_space: :itself,
                          A: :title,
                          B: :description,
                          datetime: :published_at
                        },
                        index_on_create: ->(_voting) { false },
                        index_on_update: ->(voting) { voting.visible? })

      def self.log_presenter_class_for(_log)
        Decidim::Votings::AdminLog::VotingPresenter
      end

      # Allow ransacker to search for a key in a hstore column (`title`.`en`)
      ransacker :title do |parent|
        Arel::Nodes::InfixOperation.new("->>", parent.table[:title], Arel::Nodes.build_quoted(I18n.locale.to_s))
      end

      # should remove this method when we have public views
      def self.public_spaces
        none
      end
    end
  end
end
