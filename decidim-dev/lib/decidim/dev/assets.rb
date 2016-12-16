module Decidim
  module Dev
    def self.asset(name)
      File.join(
        File.dirname(__FILE__),
        "assets",
        name
      )
    end
  end
end
