# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin imports proposals from
      # a participatory text.
      class ImportParticipatoryText < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless form.valid?

          participatory_text = save_participatory_text
          parse_participatory_text(participatory_text)

          broadcast(:ok)
        end

        private

        attr_reader :form

        def save_participatory_text
          document = ParticipatoryText.find_or_initialize_by(component: @form.current_component)
          document.update!(title: form.title, description: form.description)
        end

        def parse_participatory_text(participatory_text)
          # proposals.map do |original_proposal|
          #   next if proposal_already_copied?(original_proposal, target_component)

          #   origin_attributes = original_proposal.attributes.except(
          #     "id",
          #     "created_at",
          #     "updated_at",
          #     "state",
          #     "answer",
          #     "answered_at",
          #     "decidim_component_id",
          #     "reference",
          #     "proposal_votes_count",
          #     "proposal_notes_count"
          #   )

          #   proposal = Decidim::Proposals::Proposal.new(origin_attributes)
          #   proposal.category = original_proposal.category
          #   proposal.component = target_component
          #   proposal.save!

          #   proposal.link_resources([original_proposal], "copied_from_component")
          #   original_proposal.coauthorships.each do |coauthorship|
          #     Decidim::Coauthorship.create(author: coauthorship.author, user_group: coauthorship.user_group, coauthorable: proposal)
          #   end
          # end.compact
        end

        def proposals
          Decidim::Proposals::Proposal
            .where(component: origin_component)
            .where(state: proposal_states)
        end

        def proposal_already_copied?(original_proposal, target_component)
          original_proposal.linked_resources(:proposals, "copied_from_component").any? do |proposal|
            proposal.component == target_component
          end
        end
      end
    end
  end
end
