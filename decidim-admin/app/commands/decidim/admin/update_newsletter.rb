module Decidim
  module Admin
    class UpdateNewsletter < Rectify::Command
      def initialize(newsletter, form, user)
        @newsletter = newsletter
        @form = form
        @user = user
        @organization = user.organization
      end

      def call
        return broadcast(:invalid) unless @form.valid?
        return broadcast(:invalid) if @newsletter.sent?
        return broadcast(:invalid) unless @organization == @newsletter.organization

        @newsletter.update_attributes!(
          subject: @form.subject,
          body: @form.body,
          author: @user
        )

        broadcast(:ok, @newsletter)
      end
    end
  end
end
