class TopAppsController < ApplicationController
  # GET /
  def index
    #@joinResult = Version.joins('JOIN overpermission ON overpermission.versionID = version.versionID')
    #@joinResult2 = Version.joins(:overpermissions)
    sql = "Select * from version JOIN overpermission ON overpermission.versionID = version.versionID JOIN permission on overpermission.permissionID = permission.permissionID"
    @records_array = ActiveRecord::Base.connection.execute(sql)
  end
end