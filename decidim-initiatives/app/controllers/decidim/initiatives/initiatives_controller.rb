# frozen_string_literal: true

module Decidim
  module Initiatives
    # This controller contains the logic regarding participants initiatives
    class InitiativesController < Decidim::Initiatives::ApplicationController
      include ParticipatorySpaceContext
      redesign_participatory_space_layout only: [:show]

      helper Decidim::AttachmentsHelper
      helper Decidim::FiltersHelper
      helper Decidim::OrdersHelper
      helper Decidim::ResourceHelper
      helper Decidim::IconHelper
      helper Decidim::Comments::CommentsHelper
      helper Decidim::Admin::IconLinkHelper
      helper Decidim::ResourceReferenceHelper
      helper PaginateHelper
      helper InitiativeHelper
      helper SignatureTypeOptionsHelper

      include InitiativeSlug
      include FilterResource
      include Paginable
      include Decidim::FormFactory
      include Decidim::Initiatives::Orderable
      include TypeSelectorOptions
      include NeedsInitiative
      include SingleInitiativeType
      include Decidim::IconHelper

      helper_method :collection, :initiatives, :filter, :stats, :tabs, :panels
      helper_method :initiative_type, :available_initiative_types

      # GET /initiatives
      def index
        enforce_permission_to :list, :initiative
        return unless search.result.blank? && params.dig("filter", "with_any_state") != %w(closed)

        @closed_initiatives ||= search_with(filter_params.merge(with_any_state: %w(closed)))

        if @closed_initiatives.result.present?
          params[:filter] ||= {}
          params[:filter][:with_any_state] = %w(closed)
          @forced_closed_initiatives = true

          @search = @closed_initiatives
        end
      end

      # GET /initiatives/:id
      def show
        enforce_permission_to :read, :initiative, initiative: current_initiative
      end

      # GET /initiatives/:id/send_to_technical_validation
      def send_to_technical_validation
        enforce_permission_to :send_to_technical_validation, :initiative, initiative: current_initiative

        SendInitiativeToTechnicalValidation.call(current_initiative, current_user) do
          on(:ok) do
            redirect_to EngineRouter.main_proxy(current_initiative).initiatives_path(initiative_slug: nil), flash: {
              notice: I18n.t(
                "success",
                scope: "decidim.initiatives.admin.initiatives.edit"
              )
            }
          end
        end
      end

      # GET /initiatives/:slug/edit
      def edit
        enforce_permission_to :edit, :initiative, initiative: current_initiative
        form_attachment_model = form(AttachmentForm).from_model(current_initiative.attachments.first)
        @form = form(Decidim::Initiatives::InitiativeForm)
                .from_model(
                  current_initiative,
                  initiative: current_initiative
                )
        @form.attachment = form_attachment_model

        render layout: "decidim/initiative"
      end

      # PUT /initiatives/:id
      def update
        enforce_permission_to :update, :initiative, initiative: current_initiative

        params[:id] = params[:slug]
        params[:type_id] = current_initiative.type&.id
        @form = form(Decidim::Initiatives::InitiativeForm)
                .from_params(params, initiative_type: current_initiative.type, initiative: current_initiative)

        UpdateInitiative.call(current_initiative, @form, current_user) do
          on(:ok) do |initiative|
            flash[:notice] = I18n.t("success", scope: "decidim.initiatives.update")
            redirect_to initiative_path(initiative)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("error", scope: "decidim.initiatives.update")
            render :edit, layout: "decidim/initiative"
          end
        end
      end

      def print
        enforce_permission_to :read, :initiative, initiative: current_initiative
      end

      private

      alias current_initiative current_participatory_space

      def current_participatory_space
        return unless params["slug"]

        @current_participatory_space ||= Initiative.find(id_from_slug(params[:slug]))
      end

      def current_participatory_space_manifest
        @current_participatory_space_manifest ||= Decidim.find_participatory_space_manifest(:initiatives)
      end

      def initiatives
        @initiatives = search.result.includes(:scoped_type)
        @initiatives = reorder(@initiatives)
        @initiatives = paginate(@initiatives)
      end

      alias collection initiatives

      def search_collection
        Initiative
          .includes(scoped_type: [:scope])
          .joins("JOIN decidim_users ON decidim_users.id = decidim_initiatives.decidim_author_id")
          .where(organization: current_organization)
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_any_state: %w(open),
          with_any_type: default_filter_type_params,
          author: "any",
          with_any_scope: default_filter_scope_params,
          with_any_area: default_filter_area_params
        }
      end

      def default_filter_type_params
        %w(all) + Decidim::InitiativesType.where(organization: current_organization).pluck(:id).map(&:to_s)
      end

      def default_filter_scope_params
        %w(all global) + current_organization.scopes.pluck(:id).map(&:to_s)
      end

      def default_filter_area_params
        %w(all) + current_organization.areas.pluck(:id).map(&:to_s)
      end

      def stats
        @stats ||= InitiativeStatsPresenter.new(initiative: current_initiative)
      end

      def tabs
        @tabs ||= items.map { |item| item.slice(:id, :text, :icon) }
      end

      def panels
        @panels ||= items.map { |item| item.slice(:id, :method, :args) }
      end

      def items
        @items ||= [
          {
            enabled: @current_initiative.photos.present?,
            id: "images",
            text: t("decidim.application.photos.photos"),
            icon: resource_type_icon_key("images"),
            method: :cell,
            args: ["decidim/images_panel", @current_initiative]
          },
          {
            enabled: @current_initiative.documents.present?,
            id: "documents",
            text: t("decidim.application.documents.documents"),
            icon: resource_type_icon_key("documents"),
            method: :cell,
            args: ["decidim/documents_panel", @current_initiative]
          }
        ].select { |item| item[:enabled] }
      end
    end
  end
end
