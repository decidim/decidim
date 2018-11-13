# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the user organization.
    #
    class HelpSectionsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"
      include TranslationsHelper

      helper_method :sections

      def edit
        @form = form(HelpSectionsForm).from_model(
          OpenStruct.new(sections: sections)
        )
      end

      def update
        @form = form(HelpSectionsForm).from_params(
          params[:help_sections]
        )

        UpdateHelpSections.call(@form, current_organization) do
          on(:ok) do
            flash[:notice] = t("help_sections.success", scope: "decidim.admin")
            redirect_to action: :edit
          end

          on(:invalid) do
            flash.now[:alert] = t("help_sections.error", scope: "decidim.admin")
          end
        end
      end

      private

      def sections
        @sections ||= Decidim.participatory_space_manifests.map do |manifest|
          OpenStruct.new(
            id: manifest.name.to_s,
            content: ContextualHelpRepository.new(current_organization).find(manifest.name)
          )
        end
      end
    end
  end
end
