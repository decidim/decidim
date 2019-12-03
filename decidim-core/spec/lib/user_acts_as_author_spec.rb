# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe User do
    let(:subject) { create(:user) }

    it_behaves_like "acts as author"
  end
end
