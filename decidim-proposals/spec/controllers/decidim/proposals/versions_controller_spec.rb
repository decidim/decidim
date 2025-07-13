# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe VersionsController, versioning: true do
      let(:resource) { create(:proposal) }

      it_behaves_like "versions controller"
    end
  end
end
