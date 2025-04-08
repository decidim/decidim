# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module AdminLog
      # This class holds the logic to present a `Decidim::CollaborativeTexts::Suggestion`
      # for the `AdminLog` log.
      # Note that this is only used in updates, creation is handled by the document creation.
      #
      class SuggestionPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create"
            "decidim.collaborative_texts.admin_log.suggestion.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.collaborative_texts.suggestion"
        end

        def diff_fields_mapping
          {
            original: :array,
            replace: :array,
            nodes: :array
          }
        end

        # Private: Caches the object that will be responsible of presenting the newsletter.
        # Overwrites the method so that we can use a custom presenter to show the correct
        # path for the newsletter.
        #
        # Returns an object that responds to `present`.
        def resource_presenter
          @resource_presenter ||= Decidim::CollaborativeTexts::AdminLog::SuggestionResourcePresenter.new(action_log.resource, h, action_log.extra["resource"])
        end

        #
        # Currently, only the action "create" exists. Update this if other
        # actions are added in the future.
        def changeset
          changeset = action_log.version.changeset
          current = changeset.delete("changeset")[1]
          changeset["original"] = [nil, current["original"]]
          changeset["replace"] = [nil, current["replace"]]
          changeset["nodes"] = [nil, (current["firstNode"]..current["lastNode"]).to_a]

          Decidim::Log::DiffChangesetCalculator.new(
            changeset,
            diff_fields_mapping,
            i18n_labels_scope
          ).changeset
        end
      end
    end
  end
end
