# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        helper_method :sortitions, :sortition

        def sortitions
          @sortitions ||= Decidim::Sortitions::FilteredSortitions
                          .for(current_component)
                          .order(created_at: :desc)
                          .page(params[:page])
                          .per(Decidim::Sortitions.items_per_page)
        end

        def sortition
          @sortition ||= sortitions.find(params[:id])
        end
      end
    end
  end
end
