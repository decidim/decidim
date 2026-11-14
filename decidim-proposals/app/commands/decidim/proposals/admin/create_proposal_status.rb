# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class CreateProposalStatus < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :text_color, :bg_color, :announcement_title, :component

        def resource_class
          Decidim::Proposals::ProposalStatus
        end
      end
    end
  end
end
