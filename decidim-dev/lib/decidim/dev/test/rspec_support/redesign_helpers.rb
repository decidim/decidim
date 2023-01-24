# frozen_string_literal: true

# A collection of methods related with redesign
module RedesignHelpers
  def skip_unless_redesign_enabled(extra_message = nil)
    base_message = "REDESIGN_PREPARED - This test works when redesign is fully enabled"
    skip [base_message, extra_message].compact_blank.join(" - ") unless redesign_enabled_by_configuration?
  end

  def redesign_enabled_by_configuration?
    @redesign_enabled_by_configuration ||= Decidim.redesign_active
  end
end

RSpec.configure do |config|
  config.include RedesignHelpers
end
