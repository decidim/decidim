# frozen_string_literal: true
require_dependency "application_controller"

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      helper_method :scopes, :categories, :disabled_categories

      def new
        @form = ProposalForm.from_params({}, author: current_user)
      end

      def index
        @proposals = collection
      end

      def create
        @form = ProposalForm.from_params(params, author: current_user)

        CreateProposal.call(@form, current_feature) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")
            redirect_to proposal_path(proposal)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
            render :new
          end
        end
      end

      def show
        @proposal = collection.find(params[:id])
      end

      private

      def scopes
        @scopes ||= current_organization.scopes
      end

      def categories
        current_feature.categories.first_class.map do |category|
          parent = {category.name[I18n.locale.to_s] => category.id}

          subcategories = category.subcategories.map do |subcategory|
            {"- #{subcategory.name[I18n.locale.to_s]}" => subcategory.id}
          end

          if subcategories.any?
            subcategories << {"" => ""}
          end

          [parent , subcategories]
        end.flatten.map(&:to_a).flatten(1)
      end

      def disabled_categories
        @disabled_categories ||= current_feature.categories.first_class.includes(:subcategories).select do |category|
          category.subcategories.any?
        end.map(&:id) + [""]
      end

      def collection
        @collection ||= Proposal.where(feature: current_feature)
      end
    end
  end
end
