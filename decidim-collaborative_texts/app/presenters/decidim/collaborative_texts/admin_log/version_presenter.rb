# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module AdminLog
      # This class holds the logic to present a `Decidim::CollaborativeTexts::Version`
      # for the `AdminLog` log.
      # Note that this is only used in updates, creation is handled by the document creation.
      #
      class VersionPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "delete", "update"
            "decidim.collaborative_texts.admin_log.version.#{action}"
          else
            super
          end
        end

        def resource_name
          # rubocop:disable Style/SafeNavigationChainLength
          Decidim::Log::ResourcePresenter.new(action_log&.resource&.document, h, "title" => action_log&.resource&.document&.title).present
          # rubocop:enable Style/SafeNavigationChainLength
        end

        def i18n_labels_scope
          "activemodel.attributes.collaborative_texts.version"
        end

        def i18n_params
          {
            user_name: user_presenter.present,
            resource_name: resource_name,
            space_name: space_presenter.present
          }
        end

        def diff_fields_mapping
          {
            body: :string,
            version_number: :integer
          }
        end

        def changeset
          Decidim::Log::DiffChangesetCalculator.new(
            full_changeset,
            diff_fields_mapping,
            i18n_labels_scope
          ).changeset
        end

        def full_changeset
          action_log.version.changeset.tap do |changeset|
            changeset[:version_number] = [
              nil,
              action_log.extra.dig("extra", "version_number")
            ]
          end
        end
      end
    end
  end
end
