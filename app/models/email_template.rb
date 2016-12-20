class EmailTemplate
  include Mongoid::Document
  field :name, type: String
  field :text, type: Text
  field :subject, type: String, default: ''

  embedded_in :user

  before_destroy :clean_campaigns

  def clone
    new_at  tributes = attributes
    new_attributes.delete('id')
    EmailTemplate.create(new_attributes)
  end

  def clean_campaigns
    campaign = user.campaigns.find_by(email_template_id: id)
    campaign.destroy if campaign.present?
  end
end
