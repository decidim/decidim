# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    describe VersionsController, versioning: true do
      let(:resource) { create(:result) }

      it_behaves_like "versions controller"

      context "when the result is deleted" do
        let(:resource) do
          result = create(:result)
          result.delete
          result
        end

        it_behaves_like "versions controller denying unreadable resources"
      end
    end
  end
end
