# frozen_string_literal: true

module Decidim
  # Exposes the report resource so users can report a reportable.
  class ReportsController < Decidim::ApplicationController
    include FormFactory
    include NeedsPermission

    before_action :authenticate_user!

    skip_authorization_check if: :has_permission_class?

    def create
      ensure_access_to_action

      @form = form(Decidim::ReportForm).from_params(params)

      CreateReport.call(@form, reportable, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("decidim.reports.create.success")
          redirect_back fallback_location: root_path
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

    def ensure_access_to_action
      authorize! :report, reportable unless has_permission_class?

      enforce_permission_to :create, :moderation
    end

    def has_permission_class?
      permission_class.present?
    end

    def permission_class
      reportable.participatory_space.manifest.permissions_class
    end

    def permission_scope
      :public
    end
  end
end
