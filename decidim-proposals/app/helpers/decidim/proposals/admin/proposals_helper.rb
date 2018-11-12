# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This class contains helpers needed to format Meetings
      # in order to use them in select forms for Proposals.
      #
      module ProposalsHelper
        # Public: A formatted collection of Meetings to be used
        # in forms.
        def meetings_as_authors_selected
          return unless @proposal.present? && @proposal.official_meeting?
          @meetings_as_authors_selected ||= @proposal.authors.pluck(:id)
        end
      end
    end
  end
end
