# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ProcessStepCell < Decidim::ViewModel
      include ParticipatoryProcessHelper
      include Decidim::ModalHelper

      delegate :steps, :active_step, to: :model

      def show
        return if steps.blank?

        render
      end

      private

      def display_steps?
        [true, "true"].include? options[:display_steps]
      end

      def data
        return unless display_steps?

        { is_open: true }
      end
    end
  end
end
