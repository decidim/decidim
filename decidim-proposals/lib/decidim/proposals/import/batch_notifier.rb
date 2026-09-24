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
            next unless eligible_for_delivery?(recipient)

            create_import_notification(recipient)
            deliver_import_email(recipient) if recipient.notifications_sending_frequency == "real_time"
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
          first_record = collection.first
          return if first_record.blank?

          if creator_class_name == "Decidim::Proposals::Import::ProposalCreator"
            Decidim::Proposals::ImportMailer.proposals_imported(first_record, recipient).deliver_later
          elsif creator_class_name == "Decidim::Proposals::Import::ProposalAnswerCreator"
            Decidim::Proposals::ImportMailer.proposal_answers_imported(first_record, recipient).deliver_later
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
          participatory_spaces.flat_map do |space|
            space
              .followers
              .where(notification_types: %w(all followed-only))
              .to_a
              .select { |recipient| recipient.is_a?(Decidim::User) && !recipient.deleted? && !recipient.blocked? }
          end.uniq
        end

        def participatory_spaces
          collection
            .map(&:participatory_space)
            .compact
            .uniq
        end

        def eligible_for_delivery?(recipient)
          first_record = collection.first
          return false if first_record.blank?
          return true unless first_record.respond_to?(:can_participate?)

          first_record.can_participate?(recipient)
        end
      end
    end
  end
end
