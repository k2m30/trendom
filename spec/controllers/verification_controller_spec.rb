require 'rails_helper'

def seed_two_users(n = 20)
  User.create_with_uid_and_email('11234', 'mikhail.chuprynski@gmail.com')
  User.create_with_uid_and_email('1234', '1mikhail.chuprynski@gmail.com')
  # User.create_with_uid_and_email('234', '11mikhail.chuprynski@gmail.com')

  n.times do |i|
    emails = [Faker::Internet.email]
    Profile.create!(name: Faker::Name.name, position: Faker::Name.title << ' at ' << Faker::Company.name,
                    photo: Faker::Internet.url,
                    location: Faker::Address.city << ', ' << Faker::Address.country,
                    emails: emails, notes: {},
                    linkedin_url: Faker::Internet.url,
                    linkedin_id: i+1, emails_available: emails.size)
  end

  User.all.each do |user|
    profiles = Profile.all
    user.profiles << profiles
    user.update(revealed_ids: profiles.ids)
    rand(1..2).times do
      user.campaigns.create(profiles_ids: user.revealed_ids,
                            name: Faker::Company.name,
                            email_template_id: user.email_templates.first.id,
                            subject: Faker::Internet.email)
    end
  end
end


RSpec.describe 'Verification' do
  it 'verifies correct email' do
    seed_two_users
    expect(User.count).to be 2
    expect(Profile.count).to be 20
    expect(Campaign.count).to be > 2

    linkedin_id = 1

    hash = {'id' => linkedin_id,
            'socialType' => 'linkedin',
            'email' => 'team@trendom.io',
            'status' => 'Verified',
            'verification' => {'id' => linkedin_id,
                               'socialType' => 'linkedin',
                               'email' => 'team@trendom.io',
                               'status' => 'Verified'
            }
    }
    page.driver.post '/verification/linkedin', hash
    expect(Profile.find_by(linkedin_id: linkedin_id).verified?).to be true
  end

  it 'verifies incorrect email' do
    seed_two_users
    expect(User.count).to be 2
    expect(Profile.count).to be 20
    expect(Campaign.count).to be >= 2

    calls_left1 = User.first.calls_left
    calls_left2 = User.last.calls_left

    linkedin_id = 1

    profile = Profile.find_by(linkedin_id: linkedin_id)

    hash = {'id' => linkedin_id,
            'socialType' => 'linkedin',
            'email' => 'team2@trendom.io',
            'status' => 'NotVerified',
            'verification' => {'id' => linkedin_id,
                               'socialType' => 'linkedin',
                               'email' => 'team2@trendom.io',
                               'status' => 'NotVerified'
            }
    }

    page.driver.post '/verification/linkedin', hash

    expect(User.first.calls_left - calls_left1).to be 1
    expect(User.last.calls_left - calls_left2).to be 1

    expect(User.first.profiles.include? profile).to be false
    expect(User.last.profiles.include? profile).to be false

    expect(User.first.profiles.size).to be 19
    expect(User.last.profiles.size).to be 19

    expect(User.first.revealed_ids.include? profile.id).to be false
    expect(User.last.revealed_ids.include? profile.id).to be false

    User.first.campaigns.each do |campaign|
      expect(campaign.profiles_ids.include?(profile.id)).to be false
    end

    User.last.campaigns.each do |campaign|
      expect(campaign.profiles_ids.include?(profile.id)).to be false
    end

    expect(Profile.count).to be 20
    expect(Profile.find_by(linkedin_id: linkedin_id).not_verified?).to be true


  end

  it 'verifies failed email' do
    seed_two_users
    expect(User.count).to be 2
    expect(Profile.count).to be 20
    expect(Campaign.count).to be >= 2

    calls_left1 = User.first.calls_left
    calls_left2 = User.last.calls_left

    linkedin_id = 1
    profile = Profile.find_by(linkedin_id: linkedin_id)

    hash = {'socialType' => 'linkedin',
            'email' => 'seanl@proact.se',
            'errors' => ['Unverifiable -> None'],
            'id' => linkedin_id,
            'status' => 'Failed',
            'verification' => {'socialType' => 'linkedin',
                               'email' => 'seanl@proact.se',
                               'errors' => ['Unverifiable -> None'],
                               'id' => linkedin_id,
                               'status' => 'Failed'
            }
    }

    page.driver.post '/verification/linkedin', hash

    expect(User.first.calls_left - calls_left1).to be 0
    expect(User.last.calls_left - calls_left2).to be 0

    expect(User.first.profiles.include? profile).to be true
    expect(User.last.profiles.include? profile).to be true

    expect(User.first.profiles.size).to be 20
    expect(User.last.profiles.size).to be 20

    expect(User.first.revealed_ids.include? profile.id).to be true
    expect(User.last.revealed_ids.include? profile.id).to be true

    User.first.campaigns.each do |campaign|
      expect(campaign.profiles_ids.include?(profile.id)).to be true
    end

    User.last.campaigns.each do |campaign|
      expect(campaign.profiles_ids.include?(profile.id)).to be true
    end

    expect(Profile.count).to be 20

    expect(Profile.find_by(linkedin_id: linkedin_id).failed?).to be true
  end

end
