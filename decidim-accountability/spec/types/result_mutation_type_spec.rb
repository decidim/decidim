# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim::Accountability
  describe ResultMutationType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { ResultMutationType }
    let(:model) { create(:result) }
    let(:organization) { model.organization }

    it_behaves_like "attachable mutations"
    it_behaves_like "attachable collection mutations"
  end
end
