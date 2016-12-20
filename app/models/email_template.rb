class EmailTemplate
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :name, type: String
  field :text, type: String
  field :subject, type: String, default: ''

  embedded_in :user

  before_destroy :clean_campaigns

  def clone(user)
    new_attributes = attributes
    new_attributes.delete('_id')
    new_attributes[:name] += ' cloned'
    user.email_templates.create(new_attributes)
  end

  def clean_campaigns
    campaign = user.campaigns.find_by(email_template_id: id)
    campaign.destroy if campaign.present?
  end
end
