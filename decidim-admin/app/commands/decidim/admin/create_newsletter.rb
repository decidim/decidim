module Decidim
  module Admin
    class CreateNewsletter < Rectify::Command
      def initialize(form, user)
        @form = form
        @user = user
      end

      def call
        return broadcast(:invalid) unless @form.valid?

        newsletter = Newsletter.create!(
          subject: @form.subject,
          body: @form.body,
          author: @user,
          organization: @user.organization
        )

        broadcast(:ok, newsletter)
      end
    end
  end
end
