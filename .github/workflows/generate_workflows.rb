# frozen_string_literal: true

# code to generate all workflows from the Core workflow
out = `ls ../.. | grep "decidim-*" | grep -v "gemspec" | grep -v "design"`
out = out.split("\n")

out.each do |mod|
  name = mod.gsub("decidim-", "")
  next if name == "core"
  next if name == "generators"

  clean_name = name.capitalize.gsub("_", " ")

  `cp ci_{core,#{name}}.yml`

  `perl -pi -w -e 's/decidim-core/decidim-#{name}/' ci_#{name}.yml`
  `perl -pi -w -e 's/ Core/ #{clean_name}/' ci_#{name}.yml`
end
