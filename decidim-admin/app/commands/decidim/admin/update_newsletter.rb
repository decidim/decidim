module Decidim
  module Admin
    class UpdateNewsletter < Rectify::Command
      def initialize(newsletter, form, user)
        @newsletter = newsletter
        @form = form
        @user = user
      end

      def call
        return broadcast(:invalid) unless @form.valid?

        @newsletter.update_attributes!(
          subject: @form.subject,
          body: @form.body,
          author: @user,
          organization: @user.organization
        )

        broadcast(:ok, @newsletter)
      end
    end
  end
end
