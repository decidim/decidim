# frozen_string_literal: true

module Decidim
  module System
    # Admins are the users in charge of managing a Decidim installation.
    class Admin < ApplicationRecord
      devise :database_authenticatable, :validatable, :timeoutable

      validates :email, uniqueness: true

      validates :password, password: { email: :email }

      private

      # Changes default Devise behaviour to use ActiveJob to send async emails.
      def send_devise_notification(notification, *args)
        devise_mailer.send(notification, self, *args).deliver_later
      end
    end
  end
end
