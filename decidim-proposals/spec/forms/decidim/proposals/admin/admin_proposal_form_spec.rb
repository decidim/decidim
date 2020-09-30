# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalForm do
        it_behaves_like "a proposal form", skip_etiquette_validation: true, i18n: true
        it_behaves_like "a proposal form with meeting as author", skip_etiquette_validation: true, i18n: true
      end
    end
  end
end
