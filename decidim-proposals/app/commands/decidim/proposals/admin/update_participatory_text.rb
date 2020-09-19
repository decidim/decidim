# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin updates participatory text proposals.
      class UpdateParticipatoryText < Rectify::Command
        include Decidim::TranslatableAttributes

        # Public: Initializes the command.
        #
        # form - A PreviewParticipatoryTextForm form object with the params.
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
          transaction do
            @failures = {}
            update_contents_and_resort_proposals(form)
          end

          if @failures.any?
            broadcast(:invalid, @failures)
          else
            broadcast(:ok)
          end
        end

        private

        attr_reader :form

        # Prevents PaperTrail from creating versions while updating participatory text proposals.
        # A first version will be created when publishing the Participatory Text.
        def update_contents_and_resort_proposals(form)
          PaperTrail.request(enabled: false) do
            form.proposals.each do |prop_form|
              add_failure(prop_form) if prop_form.invalid?

              proposal = Proposal.where(component: form.current_component).find(prop_form.id)
              proposal.set_list_position(prop_form.position) if proposal.position != prop_form.position
              proposal.title = { I18n.locale => translated_attribute(prop_form.title) }
              proposal.body = if proposal.participatory_text_level == ParticipatoryTextSection::LEVELS[:article]
                                { I18n.locale => translated_attribute(prop_form.body) }
                              else
                                { I18n.locale => "" }
                              end

              add_failure(proposal) unless proposal.save
            end
          end
          raise ActiveRecord::Rollback if @failures.any?
        end

        def add_failure(proposal)
          @failures[proposal.id] = proposal.errors.full_messages
        end
      end
    end
  end
end
