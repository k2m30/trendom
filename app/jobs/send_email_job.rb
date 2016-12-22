require 'gmail'
require_relative 'email_helper'

class SendEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id, profile_id, campaign_id, email_to)
    @logger = MonoLogger.new('log/sending.log')
    @logger.level = MonoLogger::INFO
    user = User.find(user_id)
    campaign = user.campaigns.find(campaign_id)
    profile = Profile.find(profile_id)

    if Rails.env.production? or Rails.env.development?
      begin
        gmail = Gmail.connect(:xoauth2, user.email, refresh_token(user.refresh_tkn))
        email = compose_email gmail, profile, email_to, campaign, user
        email.deliver!
        @logger.info("sent test email from #{user.email} to #{profile.emails.first}")
      rescue => e
        @logger.error [user.name, profile.id]
        @logger.error e.message
        @logger.error pp e.backtrace[0..4]
      end
    end
  end
end
