# frozen_string_literal: true

module Decidim
  module Debates
    # Exposes the debate resource so users can view them
    class DebatesController < Decidim::Debates::ApplicationController
      helper Decidim::ApplicationHelper
      helper Decidim::Messaging::ConversationHelper
      include FormFactory

      helper_method :debates, :debate

      def new
        authorize! :create, Debate

        @form = form(DebateForm).instance
      end

      def create
        authorize! :create, Debate
        @form = form(DebateForm).from_params(params, current_feature: current_feature)

        CreateDebate.call(@form) do
          on(:ok) do |debate|
            flash[:notice] = I18n.t("debates.create.success", scope: "decidim.debates")
            redirect_to debate_path(debate)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("debates.create.invalid", scope: "decidim.debates")
            render action: "new"
          end
        end
      end

      def debates
        @debates ||= Debate.where(feature: current_feature)
      end

      def debate
        @debate ||= debates.find(params[:id])
      end
    end
  end
end
