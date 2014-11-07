class Version < ActiveRecord::Base
  self.primary_key = "versionID"
  has_many :overpermissions
end
