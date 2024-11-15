Device.joins(:model).where("models.nm like '%-EMLD'").order(:crm_object_id).each do |d|
  puts(d.crm_object_id)
  nm = d.model.nm
  nm.sub!(/-EMLD/,'')
  m = Model.find_by(nm: nm)
  d.update_attributes(model_id: m.id)
end

Model.where("nm like '%-EMLD'").each do |m|
  m.destroy
end