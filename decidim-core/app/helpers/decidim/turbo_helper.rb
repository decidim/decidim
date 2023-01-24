# frozen_string_literal: true

module Decidim
  # Helpers related to turbo.
  module TurboHelper
    include Turbo::FramesHelper

    def turbo_frame_options(turbo_frame, replace: true)
      return {} if turbo_frame.blank?

      turbo_action = replace ? "replace" : nil
      { data: { turbo_frame:, turbo_action: }.compact_blank }
    end
  end
end
