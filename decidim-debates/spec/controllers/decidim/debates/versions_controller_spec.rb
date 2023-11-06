# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe VersionsController, type: :controller, versioning: true do
      routes { Decidim::Debates::Engine.routes }

      let(:resource) { create(:debate) }

      it_behaves_like "versions controller"
    end
  end
end
