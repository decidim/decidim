# frozen_string_literal: true

module Decidim
  module Initiatives
    # This controller contains the logic regarding citizen initiatives
    class InitiativesController < Decidim::Initiatives::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout only: [:show]

      helper Decidim::WidgetUrlsHelper
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
      include InitiativeSlug
      include FilterResource
      include Paginable
      include Decidim::FormFactory
      include Decidim::Initiatives::Orderable
      include TypeSelectorOptions
      include NeedsInitiative
      include SingleInitiativeType

      helper_method :collection, :initiatives, :filter, :stats
      helper_method :initiative_type

      # GET /initiatives
      def index
        enforce_permission_to :list, :initiative

        return unless search.results.blank? && params.dig("filter", "state") != %w(closed)

        @closed_initiatives = search_klass.new(search_params.merge(state: %w(closed)))

        if @closed_initiatives.results.present?
          params[:filter] ||= {}
          params[:filter][:date] = %w(closed)
          @forced_closed_initiatives = true
          @search = @closed_initiatives
        end
      end

      # GET /initiatives/:id
      def show
        enforce_permission_to :read, :initiative, initiative: current_initiative
      end

      # GET /initiatives/:slug/edit
      def edit
        # enforce_permission_to :edit, :initiative, initiative: current_initiative

        form_attachment_model = form(AttachmentForm).from_model(current_initiative.attachments.first)
        @form = form(Decidim::Initiatives::Admin::InitiativeForm)
                .from_model(
                  current_initiative,
                  initiative: current_initiative
                )
        @form.attachment = form_attachment_model

        render layout: "decidim/initiative"
      end

      private

      alias current_initiative current_participatory_space

      def current_participatory_space
        @current_participatory_space ||= Initiative.find_by(id: id_from_slug(params[:slug]))
      end

      def initiatives
        @initiatives = search.results.includes(:scoped_type)
        @initiatives = reorder(@initiatives)
        @initiatives = paginate(@initiatives)
      end

      alias collection initiatives

      def search_klass
        InitiativeSearch
      end

      def default_filter_params
        {
          search_text: "",
          state: ["open"],
          type_id: default_filter_type_params,
          author: "any",
          scope_id: default_filter_scope_params,
          area_id: default_filter_area_params
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

      def context_params
        {
          organization: current_organization,
          current_user: current_user
        }
      end

      def stats
        @stats ||= InitiativeStatsPresenter.new(initiative: current_initiative)
      end
    end
  end
end
