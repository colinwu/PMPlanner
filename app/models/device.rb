class Device < ActiveRecord::Base
  attr_accessible :installed_base_id, :crm_object_id, :alternate_id, :model_id, :client_id, :serial_number, :location_id, :primary_tech_id, :backup_tech_id, :active, :under_contract, :do_pm, :pm_counter_type, :pm_visits_min, :notes, :team_id
  
  belongs_to :model
  belongs_to :client
  belongs_to :location
  belongs_to :primary_tech, :class_name => 'Technician', :foreign_key => 'primary_tech_id'
  belongs_to :backup_tech, :class_name => 'Technician', :foreign_key => 'backup_tech_id'
  belongs_to :team, :foreign_key => 'team_id'
  has_many :readings, :dependent => :destroy, :inverse_of => :device
  has_many :outstanding_pms, :dependent => :destroy
  has_many :logs
  has_one :neglected, :dependent => :destroy
  has_one :device_stat, :dependent => :destroy
  has_many :transfers, :dependent => :destroy
  
  validates :primary_tech_id, :backup_tech_id, numericality: { greater_than: 0 }, allow_nil: true
  validates :location_id, :client_id, numericality: { greater_than: 0 }
  validates :crm_object_id, :serial_number, :location_id, presence: true
  validates :crm_object_id, :serial_number, uniqueness: true
  validates_associated :model, :outstanding_pms
  
  delegate :name, to: :client , prefix: true, allow_nil: true
  delegate :nm, to: :model, prefix: true, allow_nil: true
  
  def target_for(code)
    self.model.model_group.model_targets.where(["maint_code = ?",code]).first
  end
  
  # Returns {'bw_monthly' => 0, 'c_monthly' => 0 , 'vpy' => 2.0} if 0 or 1 reading available,
  def calculate_stats
    if self.readings.count > 1
      first_reading = self.readings.order(:taken_at).first      
      last_reading = self.last_non_zero_reading_on_or_before(Date.today) 
      first_last_interval = (last_reading.taken_at - first_reading.taken_at).to_i
      if first_last_interval == 0  # for the case where there is only 1 non-zero reading
        return {'bw_monthly' => 0, 'c_monthly' => 0 , 'vpy' => 2.0}
      end
      c_monthly = 0
      c_daily = 0
      if self.model.model_group.color_flag
        first_ctotal = first_reading.counter_for('ctotal')
        first_c_val = first_ctotal.nil? ? 0 : first_ctotal.value
        last_ctotal = last_reading.counter_for('ctotal')
        last_c_val = last_ctotal.nil? ? 0 : last_ctotal.value
        c_daily = 1.0*(last_c_val - first_c_val)/first_last_interval
        c_monthly = (c_daily > 0) ? 30.5*c_daily : 0
      end
      first_bwtotal = first_reading.counter_for('bwtotal')
      first_bw_val = first_bwtotal.nil? ? 0 : first_bwtotal.value
      last_bwtotal = last_reading.counter_for('bwtotal')
      last_bw_val = last_bwtotal.nil? ? 0 : last_bwtotal.value
      bw_daily = 1.0*(last_bw_val - first_bw_val)/first_last_interval
      bw_monthly = (bw_daily > 0) ? 30.5*bw_daily : 0
      
      vpy = 2.0
      if (self.active and self.do_pm)
        vpy = 2.0*(1 + (bw_monthly + c_monthly)/self.target_for('amv').target)
      end
      return {'bw_monthly' => bw_monthly, 'c_monthly' => c_monthly , 'vpy' => vpy}
    else
      return {'bw_monthly' => 0, 'c_monthly' => 0 , 'vpy' => 2.0}
    end
  end

  def update_pm_visit_tables(codes_list = [])
    now = Date.today
    ds = DeviceStat.find_or_create_by(device_id: self.id)
    neg = Neglected.find_or_create_by(device_id: self.id)
    midnight = Time.parse(now.to_s)
    prev_reading = self.last_non_zero_reading_on_or_before(now)
    unless prev_reading.nil? 
      oldest_outstanding = self.outstanding_pms.order(:updated_at).first
      unless oldest_outstanding.nil?
#         if (oldest_outstanding.updated_at > midnight) and (oldest_outstanding.updated_at > self.readings.order(:updated_at).last.updated_at) 
#           return nil
#         end
      end
      # See if this will help with making it run faster
      pm_code = Hash.new
      PmCode.all.each do |c|
        pm_code[c.name] = c.colorclass
      end
      
      range = self.primary_tech.preference.upcoming_interval * 7 # in days
      
      stats = self.calculate_stats
      bw_monthly = stats['bw_monthly']
      c_monthly = stats['c_monthly']
      vpy = stats['vpy']
      
      ds.update_attributes(c_monthly: c_monthly, bw_monthly: bw_monthly, vpy: vpy)
      self.device_stat(true)
      
      last_now_interval = Date.today - prev_reading.taken_at
      
      ### NOTE May be able to skip this section if Total counters are not included,
      ## except that we will still need the dailyc and dailybw numbers
      dailyc = 0
      if self.model.model_group.color_flag
        dailyc = c_monthly / 30.5
      end
      
      # Calculate BW stats
      dailybw = bw_monthly / 30.5
      
      # BW and C progress % and PM Dates depend on @vpy
      visit_interval = 365 / vpy
#       next_pm_date = prev_reading.taken_at + visit_interval.round
      ###
      # Now calculate stuff for all the other PM codes
      if codes_list.empty?
        codes_list = self.model.model_group.model_targets.where("maint_code <> 'amv'").map {|t| t.maint_code }
      end
      codes_list.each do |c|
        target = self.target_for(c)
        unless target.nil? or target.target == 0
#           pm_code = PmCode.find_by name: c
          target_val = target.target
          last_val = prev_reading.counter_for(c).nil? ? 0 : prev_reading.counter_for(c).value
          if pm_code[c] == 'ALL'
            daily = dailyc + dailybw
          elsif pm_code[c] == 'COLOR'
            daily = dailyc
          elsif pm_code[c] == 'BW'
            daily = dailybw
          end
          estimate = last_val + daily * last_now_interval
          case daily
          when 0
            next_pm_date = now + 366
          else
            next_pm_date = (now + ((target_val - estimate) / daily))
          end
          if next_pm_date > now + 366
            next_pm_date = now + 366
          end
#           unless (c == 'TA' or c == 'CA')
            op = OutstandingPm.find_or_create_by(device_id: self.id, code: c)
            op.update_attributes(next_pm_date: next_pm_date)
#           end
        end # unless target.nil? or target.target == 0
      end # codes_list.each do |c|
      if self.outstanding_pms.where("next_pm_date is not NULL").empty?
        # basically, no outstanding PMs so just schedule the next PM based on vpy
        neg.update_attributes(next_visit: (prev_reading.taken_at + (365/vpy).round))
      end
    else # no previous readings, so no stats and no outstanding_pms
      neg.update_attributes(next_visit: Date.today)
    end
  end

  def last_non_zero_reading_on_or_before(date = Date.today)
    self.readings.where("taken_at <= '#{date}'").order('taken_at desc').each do |r|
      r.counters.each do |c|
        if c.value > 0
          return r
        end
      end
    end
    return nil
  end
  
  def pm_parts(choice = {})
    # 'choice" is hash where key is the PM code and value is the choice; 
    #    e.g. {'PK' => 1, 'DC' => 2} means we want choice 1 for 'PK' code and 2nd choice
    #    for 'DC' code
    
    code_list = self.outstanding_pms.map(&:code)
    pm_parts = Hash.new
    code_list.each do |c|
      all_parts = self.model.model_group.parts_for_pms.joins(:pm_code).where("pm_codes.name = ?", c).order(:choice)
      choice_list = all_parts.group(:choice).map(&:choice)
      choice[c] ||= 0
      pm_parts[c] = all_parts.where("choice = ?", choice_list[choice[c].to_i])
    end
    # pm_parts = {code => [parts], ...}
    return pm_parts
  end
  
  def transfer_to(to_team_id = 0)
    to_team = Team.find(to_team_id)
    if (to_team_id.to_i > 0) and not to_team.nil?
      if self.notes.nil?
        self.notes = Date.today.to_s + ": Initiated transfer to #{to_team.name}"
      else
        self.notes += Date.today.to_s + ": Initiated transfer to #{to_team.name}"
      end
      self.save
      t = Transfer.create(from_team_id: self.team_id, to_team_id: to_team_id, device_id: self.id)
      if t.nil?
        return false
      end
    else
      return false
    end
    true
  end
  
  def manager
    Technician.where(["manager = true and team_id = ?", self.team_id]).first
  end
  
  def pm_codes
    self.model.model_group.model_targets.where("maint_code <> 'AMV'").map {|t| PmCode.find_by_name(t.maint_code)}
  end
end
