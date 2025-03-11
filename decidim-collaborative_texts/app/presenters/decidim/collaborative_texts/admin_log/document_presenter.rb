# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module AdminLog
      # This class holds the logic to present a `Decidim::CollaborativeTexts::Document`
      # for the `AdminLog` log.
      class DocumentPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete", "update", "soft_delete", "restore", "publish", "unpublish"
            "decidim.collaborative_texts.admin_log.document.#{action}"
          else
            super
          end
        end

        def diff_fields_mapping
          {
            title: :string,
            body: :string,
            version_number: :integer
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.collaborative_texts.document"
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
              changeset[:body] = [nil, action_log&.extra&.dig("extra", "body")]
              changeset[:version_number] = [nil, "1"]
            elsif (version_number = action_log&.extra&.dig("extra", "version_number"))
              changeset[:version_number] = [nil, version_number]
            end
          end
        end
      end
    end
  end
end
