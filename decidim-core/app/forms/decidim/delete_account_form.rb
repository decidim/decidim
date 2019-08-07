# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind deleting users account.
  class DeleteAccountForm < Form
    attribute :delete_reason, String
  end
end
