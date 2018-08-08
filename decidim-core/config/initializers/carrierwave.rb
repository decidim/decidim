# frozen_string_literal: true

module CarrierWave
  module MiniMagick
    # this method allow us to specify a quality for our image
    # e.g. <process quality: 60>
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end
