# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module AdminLog
      # This class holds the logic to present a `Decidim::CollaborativeTexts::Document`
      # for the `AdminLog` log.      #
      class DocumentPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete", "update", "soft_delete", "restore"
            "decidim.collaborative_texts.admin_log.document.#{action}"
          else
            super
          end
        end

        def diff_fields_mapping
          {
            title: :string,
            body: :string
          }
        end

        # adds the body from the version to the changeset
        def changeset
          Decidim::Log::DiffChangesetCalculator.new(
            full_changeset,
            diff_fields_mapping,
            i18n_labels_scope
          ).changeset
        end

        def full_changeset
          action_log.version.changeset.tap do |changeset|
            if action == "create"
              changeset[:body] = [
                nil,
                action_log.resource.document_versions&.first&.body
              ]
            end
          end
        end
      end
    end
  end
end
