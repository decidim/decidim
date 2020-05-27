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
      include Decidim::Initiatives::Orderable
      include TypeSelectorOptions
      include NeedsInitiative

      helper_method :collection, :initiatives, :filter, :stats

      # GET /initiatives
      def index
        enforce_permission_to :list, :initiative
      end

      # GET /initiatives/:id
      def show
        enforce_permission_to :read, :initiative, initiative: current_initiative
      end

      # GET /initiatives/:id/signature_identities
      def signature_identities
        @voted_groups = InitiativesVote
                        .supports
                        .where(initiative: current_initiative, author: current_user)
                        .pluck(:decidim_user_group_id)
        render layout: false
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
          scope_id: default_filter_scope_params
        }
      end

      def default_filter_type_params
        %w(all) + Decidim::InitiativesType.where(organization: current_organization).pluck(:id).map(&:to_s)
      end

      def default_filter_scope_params
        %w(all global) + current_organization.scopes.pluck(:id).map(&:to_s)
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
