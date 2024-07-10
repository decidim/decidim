# frozen_string_literal: true

module Decidim
  module Admin
    class ShareTokenForm < Decidim::Form
      include TranslatableAttributes

      attribute :token
      attribute :expires_at
      attribute :times_used
    end
  end
end
