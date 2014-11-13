class AnalyticsController < ApplicationController
  #before_action :set_versions, only: [:show]

  # GET /
  def index
    #@joinResult = Version.joins('JOIN overpermission ON overpermission.versionID = version.versionID')
    #@joinResult2 = Version.joins(:overpermissions)
    #sql = "Select * from version JOIN overpermission ON overpermission.versionID = version.versionID JOIN permission on overpermission.permissionID = permission.permissionID"
    sql = "select AppData.*, COUNT(*) AS num_versions from AppData left outer join Version ON AppData.appId = Version.appID GROUP BY AppData.appId"
    @records_array = ActiveRecord::Base.connection.execute(sql)
  end

  # GET /analytics/1
  def show
    sql = "select * from Version WHERE appID = " + params[:id]
    @versions = ActiveRecord::Base.connection.execute(sql)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_versions
    sql = "select * from Version WHERE appID = " + params[:id]
    @versions = ActiveRecord::Base.connection.execute(sql)
  end

end