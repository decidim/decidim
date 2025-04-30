# frozen_string_literal: true

module Decidim
  # Exposes the report resource so users can report a reportable.
  class ReportsController < Decidim::ApplicationController
    include FormFactory
    include NeedsPermission

    before_action :authenticate_user!

    def create
      enforce_permission_to :create, :moderation

      @form = form(Decidim::ReportForm).from_params(params, can_hide: reportable.try(:can_be_administered_by?, current_user))

      CreateReport.call(@form, reportable, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("decidim.reports.create.success")
          redirect_to reportable.reload.reported_content_url
        end

        on(:invalid) do
          flash[:alert] = I18n.t("decidim.reports.create.error")
          redirect_back fallback_location: root_path
        end
      end
    end

    private

    def reportable
      @reportable ||= GlobalID::Locator.locate_signed params[:sgid]
    end

    def permission_class_chain
      [
        reportable.participatory_space.manifest.permissions_class,
        Decidim::Permissions
      ]
    end

    def permission_scope
      :public
    end
  end
end
