# frozen_string_literal: true
module Decidim
  module Admin
    module ExportsHelper
      def export_dropdown
        render partial: "decidim/admin/exports/dropdown"
      end
    end
  end
end
