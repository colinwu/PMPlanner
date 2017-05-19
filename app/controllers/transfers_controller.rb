class TransfersController < ApplicationController
  # TODO see if we can use before_action filter to ensure the signed-in tech is admin or manager
  before_action :authorize
  def index
    you_are_here
    @title = "All transfers"
    my_region = current_technician.team_id
    @to_me = Transfer.where(["to_team_id = ? and (accepted is NULL or accepted = FALSE)", my_region]).order('created_at desc')
    @from_me = Transfer.where(["from_team_id = ? and (accepted is NULL or accepted = FALSE)", my_region]).order('created_at desc')
  end
  
  def to_me
    you_are_here
    @title = "Transfer to me"
    my_region = current_technician.team_id
    @transfers = Transfer.where(["to_team_id = ? and (accepted is NULL or accepted = FALSE)", my_region]).order('created_at desc').page(params[:page])
  end
  
  def from_me
    you_are_here
    @title = "Transfers I initiated"
    my_region = current_technician.team_id
    @transfers = Transfer.where(["from_team_id = ? and (accepted is NULL or accepted = FALSE)", my_region]).order('created_at desc').page(params[:page])
  end
  
  def handle_checked
    unless params[:device].nil?
      dev_ids = params[:device] ? params[:device].each_key.map {|x| x} : params[:alldevs].each_key.map {|x| x}
      devices = Device.find(dev_ids)
      devices.each do |dev|
        if params[:accept]
          t = dev.transfers.first
          t.accepted = true
          t.save
          dev.team_id = t.to_team_id
          dev.primary_tech_id = nil
          dev.backup_tech_id = nil
          dev.location.contacts.delete
          dev.save
          current_technician.logs.create(device_id: dev.id, message: "Accepted transfer of device")
          flash[:notice] = "Transfer accepted"
        elsif params[:cancel]
          dev.transfers.first.destroy
          current_technician.logs.create(device_id: dev.id, message: "Cancelled transfer of device")
          flash[:notice] = "Transfer cancelled"
          # TODO Should send email to notify original receiving manager
        end
      end
    end
    redirect_to back_or_go_here()      
  end
end
