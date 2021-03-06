class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_campaign, only: [:show, :destroy, :send_out, :send_test_email]

  def new
    @profiles = (current_user.profiles.not_in(id: params[:fi]) & current_user.profiles_not_in_campaigns).take 100
    if @profiles.empty?
      redirect_to user_root_path, alert: 'There is no emails to create campaign. Mine some first.'
    end
    @campaign = current_user.campaigns.new

    @email_templates = current_user.email_templates
    redirect_to new_email_template_path, alert: 'Create at least one email template first' if @email_templates.empty?
  end

  def index
    @campaigns = current_user.campaigns
  end

  def create
    ids = current_user.campaigns.pluck(:profiles_ids).flatten
    fi = JSON(campaign_params[:hidden])['fi'] || []
    @profiles = current_user.profiles_ids - fi - ids
    @campaign = current_user.campaigns.create(profiles_ids: @profiles,
                                              name: campaign_params[:name],
                                              email_template_id: current_user.email_templates.find(campaign_params[:email_template_id]).id
    )
    @campaign.send_out if campaign_params[:send_later] == '0'
    @email_template = current_user.email_templates.find(@campaign.email_template_id)
    render :show
  end

  def send_out
    @campaign.send_out
    redirect_to campaigns_path
  end

  def send_test_email
    if params[:email].nil? or !params[:email].include?('@')
      redirect_to campaign_path(@campaign), alert: 'There is no correct email provided.'
    else
      @campaign.send_test_email(params[:email])
      redirect_to campaign_path(@campaign, email: params[:email]), notice: 'Email has been sent, check your inbox in a minute.'
    end
  end

  def show
    @email_template = current_user.email_templates.find(@campaign.email_template_id)
  end

  def destroy
    @campaign.destroy
    redirect_to campaigns_path, notice: 'Campaign was successfully destroyed.'
  end

  private
  def set_campaign
    @campaign = current_user.campaigns.find(params[:id])
  end

  def campaign_params
    params.permit(:name, :email_template_id, :hidden, :subject, :send_later)
  end
end
