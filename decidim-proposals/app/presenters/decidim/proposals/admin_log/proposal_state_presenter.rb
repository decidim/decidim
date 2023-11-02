# frozen_string_literal: true

module Decidim
  module Proposals
    module AdminLog
      class ProposalStatePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            title: :i18n,
            default: :boolean,
            token: :string,
            description: :i18n,
            css_class: :string
          }
        end
      end
    end
  end
end
