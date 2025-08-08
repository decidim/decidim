# frozen_string_literal: true

module Decidim
  module AnimationsHelper
    def success_animation
      content_tag(:div, class: "success-image") do
        content_tag(:svg, class: "animation-success__checkmark", xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 52 52") do
          concat tag(:circle, class: "animation-success__checkmark__circle", cx: "26", cy: "26", r: "25", fill: "none")
          concat tag(:path, class: "animation-success__checkmark__check", fill: "none", d: "M14.1 27.2l7.1 7.2 16.7-16.8")
        end
      end
    end
  end
end
