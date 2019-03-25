# frozen_string_literal: true

module Decidim
  module Admin
    class SelectRecipientsNewsletterParticipatorySpaceForm < Form
      mimic :scope

      attribute :name, String
      attribute :type, String
      attribute :selected, Boolean
      
    end
  end
end
