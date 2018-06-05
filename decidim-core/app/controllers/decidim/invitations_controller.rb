# frozen_string_literal: true

module Decidim
  # The controller to handle friends invitations by the current user.
  class InvitationsController < Decidim::ApplicationController
    include FormFactory

    def index
      @form = form(InvitationsForm).instance
    end

    def create
      @form = form(InvitationsForm).from_params(params)

      InviteFriends.call(@form) do
        on(:ok) do
          flash[:notice] = t("invitations.create.success", scope: "decidim")
          redirect_to account_path
        end

        on(:invalid) do
          flash[:alert] = if @form.emails.empty?
                            t("invitations.create.error_empty_form", scope: "decidim")
                          else
                            t("invitations.create.error", scope: "decidim")
                          end
          render action: :index
        end
      end
    end
  end
end
