# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the card for an instance of an Assembly member
    class AssemblyMemberCell < Decidim::ViewModel
      property :designation_date
      property :name
      property :nickname
      property :personal_information
      property :position
      property :profile_url

      private

      def has_profile?
        model.profile_url.present?
      end
    end
  end
end
