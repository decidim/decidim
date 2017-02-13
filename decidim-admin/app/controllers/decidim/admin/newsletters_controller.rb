# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing user groups at the admin panel.
    #
    class NewslettersController < ApplicationController
      def index
        authorize! :index, Newsletter
        @newsletters = collection
      end

      def new
        authorize! :create, Newsletter
        @form = form(NewsletterForm).instance
      end

      def show
        @newsletter = base_query.find(params[:id])
        email = NewsletterMailer.newsletter(current_user, @newsletter)
        @email_body = Nokogiri::HTML(email.body.decoded).css("table.container").to_s
        authorize! :read, @newsletter
      end

      def create
        newsletter = Newsletter.new(organization: current_organization)
        authorize! :create, newsletter

        @form = form(NewsletterForm).from_params(params)

        CreateNewsletter.call(@form, current_user) do
          on(:ok) do
            flash[:notice] = "BLAH"
            redirect_to action: :show, id: newsletter.id
          end

          on(:invalid) do
            flash.now[:error] = "BLAH"
            render action: :new
          end
        end
      end

      def edit
        @newsletter = base_query.find(params[:id])
        authorize! :update, @newsletter
        @form = form(NewsletterForm).from_model(@newsletter)
      end

      def deliver
        @newsletter = base_query.find(params[:id])
        authorize! :update, @newsletter

        DeliverNewsletter.call(@newsletter) do
          on(:success) do

          end

          on(:invalid) do

          end
        end
      end

      private

      def collection
        Newsletter.all
      end

      def base_query
        Newsletter.where(organization: current_organization)
      end
    end
  end
end
