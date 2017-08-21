module Decidim
  module Events
    # This module is used to be included in event classes (those inheriting from
    # `Decidim::Events::BaseEvent`) that need to send emails with the notification.
    #
    # This modules adds the needed logic to deliver emails to a given user.
    #
    # Example:
    #
    #   class MyEvent < Decidim::Events::BaseEvent
    #     include Decidim::Events::EmailEvent
    #   end
    module EmailEvent
      extend ActiveSupport::Concern

      included do
        types << :email
      end
    end
  end
end
