# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Proposals
    module Admin
      module Picker
        extend ActiveSupport::Concern

        included do
          include ::Webpacker::Helper
          helper Decidim::Proposals::Admin::ProposalsPickerHelper
        end

        def proposals_picker
          render :proposals_picker, layout: false
        end
      end
    end
  end
end
