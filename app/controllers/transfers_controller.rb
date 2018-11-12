class TransfersController < ApplicationController
  # TODO see if we can use before_action filter to ensure the signed-in tech is admin or manager
  before_action :authorize, :set_defaults, :fetch_news, :require_manager
  
  def index
    you_are_here
    @title = "All transfers"
    my_region = current_technician.team_id
    @to_me = Transfer.where(["to_team_id = ? and (accepted is NULL or accepted = FALSE)", my_region]).order('created_at desc')
    @from_me = Transfer.where(["from_team_id = ? and (accepted is NULL or accepted = FALSE)", my_region]).order('created_at desc')
  end
  
  def create
    @transfer = Transfer.new(transfer_params)
    if (@transfer.save and @transfer.tx_file_name)
      current_user.logs.create(message: "Processing device transfer file #{@transfer.tx_file_name}")
      tx_file = @transfer.tx.path
      if File.exists?(tx_file)
        t = CsvMapper.import(tx_file) do
          start_at_row 0
          [dev_id, primary, backup]
        end
        t.each do |row|
          dev = Device.find_by crm_object_id: row.dev_id
          if dev.nil?
            current_user.logs.create(message: "Device with CRM ID #{row.dev_id} not found in the database.")
            next
          end
          if row.primary.nil?
            pt = Technician.find_by crm_id: dev.primary_tech_id
            current_user.logs.create(device_id: dev.id, message: "Leaving primary tech unchanged.")
          else
            pt = Technician.find_by crm_id: row.primary
            if pt.nil?
              current_user.logs.create(message: "Technician with CRM ID #{row.primary} not found in the database.")
              next
            end
          end

          # supplied backup == nil means leave unchanged; == 0 means to remove backup tech
          if row.backup.nil?
            bt = Technician.find_by crm_id: dev.backup_tech_id
            current_user.logs.create(device_id: dev.id, message: "Leaving backup tech unchanged.")
          elsif row.backup == "0"
            bt = nil
            current_user.logs.create(device_id: dev.id, message: "Removing backup tech.")
          else
            bt = Technician.find_by crm_id: row.backup
            if bt.nil?
              current_user.logs.create(device_id: dev.id, message: "New backup tech not found in the database. Old backup tech was #{dev.backup_tech_id}")
            end
          end
          
          dev.update_attributes(primary_tech_id: pt.id, backup_tech_id: bt.try(:id))
        end
      else
        current_user.logs.create(message: "Can't open transfer file #{@transfer.tx_file_name}")
        return
      end
    end
    redirect_to back_or_go_here(), notice: "Finished processing #{@transfer.tx_file_name}"
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

  private
  
  def transfer_params
    params.require(:transfer).permit( :tx )
  end
end
