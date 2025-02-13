# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module AdminLog
      # This class holds the logic to present a `Decidim::CollaborativeTexts::Version`
      # for the `AdminLog` log.      #
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
          Decidim::Log::ResourcePresenter.new(action_log.resource.document, h, "title" => action_log.resource.document.title).present
        end

        def space_presenter
          @space_presenter ||= Decidim::Log::SpacePresenter.new(
            action_log.resource.document.participatory_space,
            h,
            "title" => action_log.resource.document.participatory_space.title
          )
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
            body: :string
          }
        end
      end
    end
  end
end
