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
            case recipient.notifications_sending_frequency
            when "real_time"
              deliver_import_email(recipient)
            when "daily", "weekly"
              create_import_notification(recipient)
            end
          end
        end

        private

        attr_reader :collection, :context

        def creator_class
          context[:import_creator_class]
        end

        def creator_class_name
          klass = creator_class
          klass.is_a?(Class) ? klass.name : klass.to_s
        end

        def deliver_import_email(recipient)
          if creator_class_name == "Decidim::Proposals::Import::ProposalCreator"
            Decidim::Proposals::ImportMailer.proposals_imported(collection, recipient).deliver_later
          elsif creator_class_name == "Decidim::Proposals::Import::ProposalAnswerCreator"
            Decidim::Proposals::ImportMailer.proposal_answers_imported(collection, recipient).deliver_later
          end
        end

        def create_import_notification(recipient)
          return if collection.blank?

          event_name, extra = import_notification_details
          return if event_name.blank?

          Decidim::NotificationGeneratorForRecipient.new(
            event_name,
            Decidim::Proposals::ImportBatchEvent,
            collection.first,
            recipient,
            :follower,
            extra
          ).generate
        end

        def import_notification_details
          case creator_class_name
          when "Decidim::Proposals::Import::ProposalCreator"
            ["decidim.events.proposals.proposals_imported", { imported_count: collection.size }]
          when "Decidim::Proposals::Import::ProposalAnswerCreator"
            ["decidim.events.proposals.proposals_answers_imported", { imported_count: collection.size }]
          else
            [nil, {}]
          end
        end

        def recipients
          return [] unless participatory_space

          participatory_space
            .followers
            .where(notification_types: %w(all followed-only))
            .to_a
            .select { |recipient| recipient.is_a?(Decidim::User) && !recipient.deleted? && !recipient.blocked? }
            .uniq
        end

        def participatory_space
          context[:current_participatory_space] || collection.first&.participatory_space
        end
      end
    end
  end
end
