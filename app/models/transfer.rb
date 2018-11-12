class Transfer < ApplicationRecord

  has_attached_file :tx, styles: {}, path: ":rails_root/public/system/transfers/:filename"
  validates_attachment_file_name :tx, matches: [/\.csv\z/]
end
