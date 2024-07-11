# frozen_string_literal: true

module Decidim
  module Admin
    class CreateShareToken < Decidim::Command
      def initialize(form, share_token)
        @form = form
        @share_token = share_token
      end

      def call
        return broadcast(:invalid) if form.invalid?

        ShareToken.create!(component: share_token, token: form.token)
        broadcast(:ok)
      end

      private

      attr_reader :form, :share_token
    end
  end
end
