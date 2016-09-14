class VerificationController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:linkedin]

  def linkedin
    profile = Profile.find_by(linkedin_id: params['id'])
    if profile.nil?
      logger.fatal('Something wrong with validation')
      logger.fatal(params)
      render plain: params.permit!.to_h, status: :not_found
      return
    end

    if params['status'] == 'Verified'
      profile.update(verified: true)
    elsif params['status'] == 'NotVerified'
      ActiveRecord::Base.transaction do
        profile.emails = profile.emails - [params['email']]
        profile.emails_available = profile.emails.size
        profile.verified = false
        profile.save

        users = profile.users
        users.each do |user|
          if user.revealed_ids.include? profile.id
            user.revealed_ids = user.revealed_ids - [profile.id]
            user.calls_left += 1
          end
          user.campaigns.where(sent: false).each do |campaign|
            campaign.profiles_ids = campaign.profiles_ids - [profile.id]
            campaign.save
          end
          user.profiles.delete(profile)
          user.save
        end
      end
    end
    logger.warn params.permit!.to_h
    render plain: params.permit!.to_h, status: :ok
    return
  end
end
