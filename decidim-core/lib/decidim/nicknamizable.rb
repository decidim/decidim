# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to nicknames.
  module Nicknamizable
    def nickname_length
      (0...20)
    end

    def nicknamize(name)
      disambiguate(name.parameterize(separator: "_")[nickname_length])
    end

    private

    def disambiguate(name)
      candidate = name

      2.step do |n|
        return candidate unless exists?(nickname: candidate)

        candidate = "#{candidate}_#{n}"
      end
    end
  end
end
