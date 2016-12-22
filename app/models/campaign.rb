require 'gmail'

class Campaign
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :name
  field :sent, type: Boolean, default: false
  field :date_sent, type: DateTime
  field :progress, type: Float, default: 0.0
  field :email_template_id, type: BSON::ObjectId
  field :profiles_ids, type: Array

  embedded_in :user

  def email_template
    user.find(email_template_id)
  end

  def send_out
    if Rails.env.test? #or Rails.env.development?
      SendBatchEmailsJob.set(queue: 'test').perform_now(id.to_s, user.email, user.tkn, user.name)
    else
      SendBatchEmailsJob.set(queue: user.name.to_sym).perform_later(id.to_s, user.email, user.refresh_tkn, user.name)
    end
  end

  def email_template_name
    user.email_templates.find(email_template_id).name
  end

  def send_test_email(email_to)
    SendEmailJob.set(queue: user.name.to_sym).perform_later(user.id.to_s, profiles_ids.sample, id.to_s, email_to)
  end

  def profiles
    Profile.in(id: profiles_ids)
  end

  def status
    return 'Sent' if sent?
    return 'In progress' if progress > 0
    'Ready to start'
  end
end
