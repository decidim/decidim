# frozen_string_literal: true

require "action_dispatch/system_testing/test_helpers/screenshot_helper"

module ActionDispatch
  module SystemTesting
    module TestHelpers
      module ScreenshotHelper
        private

        # Customize the screenshot helper to fix the file paths for examples that have
        # unallowed characters in them. Otherwise the artefacts creation and upload
        # fails at GitHub actions. See the list of unallowed characters from:
        # https://github.com/actions/toolkit/blob/main/packages/artifact/docs/additional-information.md#non-supported-characters
        def image_name
          # By default, this only cleans up the forward and backward slash characters.
          sanitized_method_name = method_name.tr("/\\()\":<>|*?", "-----------")
          name = "#{unique}_#{sanitized_method_name}"
          name[0...225]
        end
      end
    end
  end
end
