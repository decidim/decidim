# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/categorizable_interface_examples"
require "decidim/core/test/shared_examples/scopable_interface_examples"
require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/authorable_interface_examples"

module Decidim
  module Meetings
    describe MeetingType, type: :graphql do
      include_context "with a graphql type"
      let(:component) { create(:meeting_component) }
      let(:model) { create(:meeting, component: component) }

      include_examples "categorizable interface"
      include_examples "scopable interface"
      include_examples "attachable interface"
      include_examples "authorable interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the meeting's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end
    end
  end
end
