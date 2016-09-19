# frozen_string_literal: true
module Decidim
  module System
    # Admins are the users in charge of managing a Decidim installation.
    class Admin < ApplicationRecord
      devise :database_authenticatable, :recoverable, :rememberable, :validatable
    end
  end
end
