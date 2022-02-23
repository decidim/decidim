# frozen_string_literal: true

#
# Copyright (c) 2018 David Rodríguez - The MIT License (MIT)
# Originally copied from https://gitlab.com/deivid-rodriguez/system_test_html_screenshots
#

require "action_dispatch/system_testing/test_helpers/screenshot_helper"

module ActionDispatch
  module SystemTesting
    module TestHelpers
      module ScreenshotHelper
        def take_screenshot
          save_image
          save_page
          # rubocop:disable Rails/Output
          puts display_screenshot
          # rubocop:enable Rails/Output
        end

        private
        # This method is not needed after update to Rails 7.0
        def _screenshot_counter
          @_screenshot_counter ||= 0
          @_screenshot_counter += 1
        end

        # Customize the screenshot helper to fix the file paths for examples that have
        # unallowed characters in them. Otherwise the artefacts creation and upload
        # fails at GitHub actions. See the list of unallowed characters from:
        # https://github.com/actions/toolkit/blob/main/packages/artifact/docs/additional-information.md#non-supported-characters
        def image_name
          # By default, this only cleans up the forward and backward slash characters.
          sanitized_method_name = method_name.tr("/\\()\":<>|*?", "-----------")
          # The unique method is automatically available after update to Rails 7.0,
          # so the following line can be removed after upgrade to Rails 7.0.
          unique = failed? ? "failures" : (_screenshot_counter || 0).to_s
          name = "#{unique}_#{sanitized_method_name}"
          name[0...225]
        end

        def image_path
          @image_path ||= absolute_image_path.to_s
        end

        def page_path
          @page_path ||= absolute_page_path.to_s
        end

        def absolute_page_path
          Rails.root.join("tmp/screenshots/#{image_name}.html")
        end

        def save_page
          page.save_page(absolute_page_path)
        end

        def display_screenshot
          message = "[Image screenshot]: file://#{image_path}\n"
          message += "       [Page HTML]: file://#{page_path}\n"

          case output_type
          when "artifact"
            message << "\e]1338;url=artifact://#{absolute_image_path}\a\n"
          when "inline"
            name = inline_base64(File.basename(absolute_image_path))
            image = inline_base64(File.read(absolute_image_path))
            message << "\e]1337;File=name=#{name};height=400px;inline=1:#{image}\a\n"
          end

          message
        end
      end
    end
  end
end
