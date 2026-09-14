# frozen_string_literal: true

namespace :decidim do
  namespace :two_factor do
    # cmd: $ RAILS_ENV=<environment> bundle exec rails decidim:two_factor:reset EMAIL=<account email> HOST=<organization host>
    desc "Remove all the second factors from the account given by EMAIL and HOST"
    task reset: :environment do
      organization = Decidim::Organization.find_by(host: ENV.fetch("HOST", nil))
      abort("No organization found for the given HOST") if organization.blank?

      user = organization.users.find_by(email: ENV.fetch("EMAIL", nil)&.downcase)
      abort("No account found for the given EMAIL") if user.blank?

      Decidim::TwoFactor::ResetUser.call(user) do
        on(:ok) { puts "Second factors removed; #{user.email} signs in with the password alone now." }
        on(:invalid) { abort("The account has no second factor to remove") }
      end
    end
  end
end
