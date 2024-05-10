# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeHelper do
      context "with humanize_admin_state" do
        let(:available_states) { [:created, :validating, :discarded, :published, :rejected, :accepted] }

        it "All states have a translation" do
          available_states.each do |state|
            expect(humanize_admin_state(state)).not_to be_blank
          end
        end
      end
    end
  end
end
