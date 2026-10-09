# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ProcessPhaseCell < Decidim::ViewModel
      include ParticipatoryProcessHelper
      include Decidim::ModalHelper

      delegate :phases, :active_phase, to: :model

      def show
        return if phases.blank?

        render
      end

      private

      def display_phases?
        [true, "true"].include? options[:display_phases]
      end

      def data
        return unless display_phases?

        { is_open: true }
      end
    end
  end
end
