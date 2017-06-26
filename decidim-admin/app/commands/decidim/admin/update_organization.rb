# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic for updating the current
    # organization.
    class UpdateOrganization < Rectify::Command
      # Public: Initializes the command.
      #
      # organization - The Organization that will be updated.
      # form - A form object with the params.
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_organization

        if @organization.valid?
          broadcast(:ok, @organization)
        else
          form.errors.add(:official_img_header, @organization.errors[:official_img_header]) if @organization.errors.include? :official_img_header
          form.errors.add(:official_img_footer, @organization.errors[:official_img_footer]) if @organization.errors.include? :official_img_footer
          broadcast(:invalid)
        end
      end

      private

      attr_reader :form, :organization

      def update_organization
        @organization.assign_attributes(attributes)
        @organization.save! if @organization.valid?
      end

      def attributes
        {
          name: form.name,
          twitter_handler: form.twitter_handler,
          facebook_handler: form.facebook_handler,
          instagram_handler: form.instagram_handler,
          youtube_handler: form.youtube_handler,
          github_handler: form.github_handler,
          description: form.description,
          welcome_text: form.welcome_text,
          homepage_image: form.homepage_image,
          remove_homepage_image: form.remove_homepage_image,
          logo: form.logo,
          remove_logo: form.remove_logo,
          favicon: form.favicon,
          remove_favicon: form.remove_favicon,
          default_locale: form.default_locale,
          official_img_header: form.official_img_header,
          remove_official_img_header: form.remove_official_img_header,
          official_img_footer: form.official_img_footer,
          remove_official_img_footer: form.remove_official_img_footer,
          official_url: form.official_url,
          show_statistics: form.show_statistics
        }
      end
    end
  end
end
