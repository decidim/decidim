# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class CreateProposalState < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :default, :token, :include_in_stats, :css_class, :answerable, :notifiable, :gamified, :announcement_title, :component

        def resource_class
          Decidim::Proposals::ProposalState
        end
      end
    end
  end
end
