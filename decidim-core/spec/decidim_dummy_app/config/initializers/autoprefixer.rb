# frozen_string_literal: true

module AutoprefixerRails
  class Sprockets
    singleton_class.send(:alias_method, :call_original, :call)

    def self.call(input)
      filename = input[:name]

      # Disable autoprefixer for the graphiql-rails gem's assets because it
      # breaks some of the API tests when the '-webkit' prefixes are applied to
      # its CSS.
      return if filename.match?(%r{^graphiql/.*})

      call_original(input)
    end
  end
end
