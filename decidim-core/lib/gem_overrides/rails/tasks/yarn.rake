# frozen_string_literal: true

# This is overridden because of a bug in Rails 6.0 which forces the yarn:install
# task to the end of assets:precompile task which fails when bin/yarn has been
# removed from Decidim applications. This should be fixed with Rails 6.1.
#
# See:
# https://git.io/JEH9s (and the equivalent line in Rails 6.1)
# https://github.com/rails/rails/commit/87e9ae053d661daa3b8549e1cc9ea5ecd3b8ad62
