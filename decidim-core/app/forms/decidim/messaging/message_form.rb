# frozen_string_literal: true

module Decidim
  module Messaging
    # A form object to be used when sending a message
    class MessageForm < Decidim::Form
      mimic :message

      attribute :body, Decidim::Attributes::CleanString

      validates :body, presence: true
    end
  end
end
