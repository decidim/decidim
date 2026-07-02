# frozen_string_literal: true

module Decidim
  module Proposals
    module Import
      class BatchNotifier
        def initialize(collection:, context:)
          @collection = Array(collection).compact
          @context = context
        end

        def notify!
          return if collection.blank?

          recipients.each do |recipient|
            case creator_class
            when Decidim::Proposals::Import::ProposalCreator
              Decidim::Proposals::ImportMailer.proposals_imported(collection, recipient).deliver_later
            when Decidim::Proposals::Import::ProposalAnswerCreator
              Decidim::Proposals::ImportMailer.proposal_answers_imported(collection, recipient).deliver_later
            end
          end
        end

        private

        attr_reader :collection, :context

        def creator_class
          context[:import_creator_class]
        end

        def recipients
          collection
            .flat_map { |elem| elem.participatory_space.followers.where(notification_types: %w(all followed-only)).to_a }
            .uniq
        end
      end
    end
  end
end