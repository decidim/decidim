# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing newsletters.
    class NewslettersController < Decidim::Admin::ApplicationController
      include Decidim::NewslettersHelper
      include Decidim::Admin::NewslettersHelper

      def index
        enforce_permission_to :read, :newsletter
        @newsletters = collection.order(Newsletter.arel_table[:created_at].desc)
      end

      def new
        enforce_permission_to :create, :newsletter
        @form = form(NewsletterForm).instance
      end

      def show
        @newsletter = collection.find(params[:id])
        @email = NewsletterMailer.newsletter(current_user, @newsletter)
        enforce_permission_to :read, :newsletter, newsletter: @newsletter
      end

      def preview
        @newsletter = collection.find(params[:id])
        enforce_permission_to :read, :newsletter, newsletter: @newsletter

        email = NewsletterMailer.newsletter(current_user, @newsletter)
        Premailer::Rails::Hook.perform(email)
        render html: email.html_part.body.decoded.html_safe
      end

      def create
        enforce_permission_to :create, :newsletter
        @form = form(NewsletterForm).from_params(params)

        CreateNewsletter.call(@form, current_user) do
          on(:ok) do |newsletter|
            flash.now[:notice] = I18n.t("newsletters.create.success", scope: "decidim.admin")
            redirect_to action: :show, id: newsletter.id
          end

          on(:invalid) do |newsletter|
            @newsletter = newsletter
            flash.now[:error] = I18n.t("newsletters.create.error", scope: "decidim.admin")
            render action: :new
          end
        end
      end

      def edit
        @newsletter = collection.find(params[:id])
        enforce_permission_to :update, :newsletter, newsletter: @newsletter
        @form = form(NewsletterForm).from_model(@newsletter)
      end

      def update
        @newsletter = collection.find(params[:id])
        enforce_permission_to :update, :newsletter, newsletter: @newsletter
        @form = form(NewsletterForm).from_params(params)

        UpdateNewsletter.call(@newsletter, @form, current_user) do
          on(:ok) do |newsletter|
            flash[:notice] = I18n.t("newsletters.update.success", scope: "decidim.admin")
            redirect_to action: :show, id: newsletter.id
          end

          on(:invalid) do |newsletter|
            @newsletter = newsletter
            flash.now[:error] = I18n.t("newsletters.update.error", scope: "decidim.admin")
            render action: :edit
          end
        end
      end

      def destroy
        @newsletter = collection.find(params[:id])
        enforce_permission_to :destroy, :newsletter, newsletter: @newsletter

        DestroyNewsletter.call(@newsletter, current_user) do
          on(:already_sent) do
            flash.now[:error] = I18n.t("newsletters.destroy.error_already_sent", scope: "decidim.admin")
            redirect_to :back
          end

          on(:ok) do
            flash[:notice] = I18n.t("newsletters.destroy.success", scope: "decidim.admin")
            redirect_to action: :index
          end
        end
      end

      def select_recipients_to_deliver
        @newsletter = collection.find(params[:id])
        enforce_permission_to :update, :newsletter, newsletter: @newsletter
        @form = form(SelectiveNewsletterForm).from_model(@newsletter)
      end

      def deliver
        @newsletter = collection.find(params[:id])
        enforce_permission_to :update, :newsletter, newsletter: @newsletter
        @form = form(SelectiveNewsletterForm).from_params(params)


        # Moved to QUERY
        spaces = @form.participatory_space_types.map do |type|
          next if type.ids.blank?
          object_class = "Decidim::#{type.manifest_name.classify}"
          object_class.constantize.where(id: type.ids.reject(&:blank?))
        end.flatten.compact

        ## QUI ES UN FOLLOWER? tots els que fan follow a algun dels components del proces, no? o nomes al proces?

        # Només s'enviarà als followes de l'espai per evitar SPAM
        followers = Decidim::Follow.user_follower_for_participatory_spaces(spaces).uniq
        
        # followers = spaces.map do |space|
        #   space.followers
        # end.flatten.compact.uniq

        # Qui es un participant?
        # - Ha comentat
        # - Ha creat una proposta
        # - Ha creat un debat
        # - Assisteix a un meeting.
        # participants =

        raise
        recipients = Decidim::Admin::SelectiveNewsletterRecipients.new(@newsletter.organization, @form)

        raise
        DeliverNewsletter.call(@newsletter, @form, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("newsletters.deliver.success", scope: "decidim.admin")
            redirect_to action: :index
          end

          on(:invalid) do
            flash[:error] = I18n.t("newsletters.deliver.error", scope: "decidim.admin")
            redirect_to action: :show
          end
        end
      end

      private

      def collection
        Newsletter.where(organization: current_organization)
      end
    end
  end
end
