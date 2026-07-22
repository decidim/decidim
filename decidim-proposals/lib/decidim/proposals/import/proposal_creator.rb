# frozen_string_literal: true

module Decidim
  module Proposals
    module Import
      # This class is responsible for creating the imported proposals
      # and must be included in proposals component's import manifest.
      class ProposalCreator < Decidim::Admin::Import::Creator
        class << self
          def batch_notifier_klass
            require_dependency "decidim/proposals/import/batch_notifier"
            Decidim::Proposals::Import::BatchNotifier
          end
        end

        # Returns the resource class to be created with the provided data.
        def self.resource_klass
          Decidim::Proposals::Proposal
        end

        # Returns a verifier class to be used to verify the correctness of the
        # import data.
        def self.verifier_klass
          Decidim::Proposals::Import::ProposalsVerifier
        end

        def initialize(data, context = nil)
          @data = data.except(:id, "id")
          @context = context
        end

        # Produces a proposal from parsed data
        #
        # Returns a proposal
        def produce
          resource.add_coauthor(context[:current_user])

          resource
        end

        # Saves the proposal
        def finish!
          finish_without_notify!
          notify(resource)
          publish(resource)
        end

        def finish_without_notify!
          Decidim.traceability.perform_action!(:create, self.class.resource_klass, context[:current_user], visibility: "admin-only") do
            resource.save!
            resource
          end
        end

        def resource
          @resource ||= Decidim::Proposals::Proposal.new(
            taxonomies:,
            scope:,
            title:,
            body:,
            address:,
            latitude:,
            longitude:,
            component:,
            published_at: Time.current
          )
        end

        def taxonomies
          id = normalize_ids(taxonomies_raw_ids)
          Decidim::Taxonomy.where(id:)
        end

        def scope
          id = normalize_id(scope_raw_id)
          Decidim::Scope.find_by(id:)
        end

        def title
          locale_hasher("title", available_locales)
        end

        def body
          locale_hasher("body", available_locales)
        end

        def address
          data.has_key?(:address) ? data[:address] : nil
        end

        def latitude
          data.has_key?(:latitude) ? data[:latitude] : nil
        end

        def longitude
          data.has_key?(:longitude) ? data[:longitude] : nil
        end

        def available_locales
          @available_locales ||= component.participatory_space.organization.available_locales
        end

        def component
          context[:current_component]
        end

        def notify(proposal)
          return if proposal.coauthorships.empty?

          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_published",
            event_class: Decidim::Proposals::PublishProposalEvent,
            resource: proposal,
            followers: coauthors_followers(proposal)
          )
        end

        def publish(proposal)
          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_published",
            event_class: Decidim::Proposals::PublishProposalEvent,
            resource: proposal,
            followers: proposal.participatory_space.followers - coauthors_followers(proposal),
            extra: {
              participatory_space: true
            }
          )
        end

        def coauthors_followers(proposal)
          @coauthors_followers ||= proposal.authors.flat_map(&:followers)
        end

        def taxonomies_raw_ids
          return extract_ids(data[:taxonomies]) if data.has_key?(:taxonomies)

          data[:"taxonomies/ids"]
        end

        def scope_raw_id
          return extract_id(data[:scope]) if data.has_key?(:scope)

          data[:"scope/id"]
        end

        def extract_ids(value)
          return value["ids"] if value.is_a?(Hash)
          return value.map { |item| extract_id(item) } if value.is_a?(Array)

          value
        end

        def extract_id(value)
          return value["id"] if value.is_a?(Hash)
          return value.id if value.respond_to?(:id)

          value
        end

        def normalize_ids(raw_ids)
          values = case raw_ids
                   when nil
                     []
                   when String
                     raw_ids.split(",")
                   when Array
                     raw_ids.flatten
                   else
                     [raw_ids]
                   end

          values.filter_map do |value|
            next if value.blank?
            next unless value.respond_to?(:to_i)

            value.to_i
          end
        end

        def normalize_id(raw_id)
          normalize_ids(raw_id).first
        end
      end
    end
  end
end
