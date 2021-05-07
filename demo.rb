my_user = Decidim::User.where(email: "admin@example.org")

my_user.first.update!(last_sign_in_at: Time.current - 2.days)

Decidim::Gamification.reset_badges(my_user)

users = Decidim::User.where(organization: my_user.first.organization ) - my_user
names = Decidim::Gamification.badges.map(&:name)
users.each do |user|
  names.each do |name|
    puts("Setting score value for user id: ##{user.id} badge #{name}")
    Decidim::Gamification.set_score(user, name.to_sym, rand(150))
  end
end
