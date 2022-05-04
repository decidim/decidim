# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Admin
      describe Draw do
        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: organization) }
        let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
        let(:target_items) { ::Faker::Number.number(digits: 2).to_i }
        let(:seed) { Time.now.utc.to_i * ::Faker::Number.between(from: 1, to: 6).to_i }
        let!(:proposals) do
          create_list(:proposal, target_items * 2,
                      component: proposal_component,
                      created_at: Time.now.utc - 1.day)
        end
        let(:sortition) do
          double(
            target_items: target_items,
            seed: seed,
            category: nil,
            request_timestamp: Time.now.utc,
            decidim_proposals_component: proposal_component
          )
        end
        let(:initial_draw) { Draw.for(sortition) }

        it "Draw can be reproduced several times" do
          expect(Draw.for(sortition)).to eq(initial_draw)
        end
      end
    end
  end
end
