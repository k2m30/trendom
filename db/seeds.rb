Profile.destroy_all
User.first.campaigns.destroy_all
profiles_ids = []
20.times do
  emails = []
  rand(1..3).times do
    emails << %w(1m@tut.by mikhail.chuprynski@gmail.com nikolay.lagutko@gmx.com nikolay.lagutko@mail.com).sample
  end

  profile = Profile.create(first_name: Faker::Name.first_name,
                             last_name: Faker::Name.last_name,
                             headline: Faker::Name.title << ' at ' << Faker::Company.name,
                             picture_url: Faker::Internet.url,
                             main_location: {name: Faker::Address.city << ', ' << Faker::Address.country},
                             corporate_emails: emails.map { |e| {email: e} },
                             site_standard_request: {url: Faker::Internet.url},
                             id: Faker::Number.number(7)
  )
  profiles_ids << profile.id
end

User.first.update(calls_left: 300, subscription_expires: Time.now + 1.month, profiles_ids: profiles_ids)