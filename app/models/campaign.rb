require 'gmail'

class Campaign
  include Mongoid::Document
  
  embedded_in :user
  has_many :email_templates, through: :user

  # serialize :profiles_ids

  def send_out
    if Rails.env.test? #or Rails.env.development?
      SendBatchEmailsJob.set(queue: 'test').perform_now(id, user.email, user.tkn, user.name)
    else
      SendBatchEmailsJob.set(queue: user.name.to_sym).perform_later(id, user.email, user.refresh_tkn, user.name)
    end
  end

  def email_template_name
    EmailTemplate.find(email_template_id).name
  end

  def send_test_email(email_to)
    SendEmailJob.set(queue: user.name.to_sym).perform_later(profiles_ids.sample, id, email_to, user.email, user.refresh_tkn, user.name)
  end

  def profiles
    Profile.where(id: profiles_ids)
  end

  def status
    return 'Sent' if sent?
    return 'In progress' if progress > 0
    'Ready to start'
  end
end
