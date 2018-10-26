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
        def meetings_selected
          @meetings_selected ||= @proposal.authors.pluck(:id) if @proposal.present?
        end
      end
    end
  end
end
