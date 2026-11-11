# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe VersionsController, versioning: true do
      let(:resource) { create(:debate) }

      it_behaves_like "versions controller"

      context "when the debate is hidden" do
        let(:resource) { create(:debate, :hidden) }

        it_behaves_like "versions controller denying unreadable resources"
      end
    end
  end
end
