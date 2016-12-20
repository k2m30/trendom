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
      profile.verified!
    elsif params['status'] == 'NotVerified'

      profile.emails = profile.emails - [params['email']]
      profile.emails_available = profile.emails.size
      profile.verified = :not_verified
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

    elsif params['status'] == 'Failed'
      profile.update(notes: params['verification'].permit!.to_h, verified: :failed)
    end
    render plain: params.permit!.to_h, status: :ok
    return
  end

  def find_user
    @info = JSON.pretty_generate(Rapportive.new.find_user(params[:email])) unless params[:email].nil?
  end
end
