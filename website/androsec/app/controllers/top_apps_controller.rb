class TopAppsController < ApplicationController
  # GET /
  def index
    @app_names = ["F-Droid", "2048", "Music", "GitHub", "VLC"]
    app_ids = [357, 465, 380, 1136, 1053]

    @overpermission_array = Array.new
    @violation_array = Array.new

    app_ids.each do |id|

      # Grab all versions for this app
      sqlVersions = "select * from Version WHERE appID = " + id.to_s + " ORDER BY build_number ASC"
      versions = ActiveRecord::Base.connection.execute(sqlVersions)

      overpermissionCount = 0
      defectsPerKLOC = 0

      versions.each do |version|

        # Get max count of permissions
        sqlOverpermissions = "select Count(*) as num_over_permissions from OverPermission where versionID = " + version["versionID"].to_s
        numOverpermissions = ActiveRecord::Base.connection.execute(sqlOverpermissions)
        overpermissionCount = [numOverpermissions.first["num_over_permissions"], overpermissionCount].max

        # Get max count of violations/kloc
        sqlSonar = "select * from CodingStandard where versionID = " + version["versionID"].to_s
        sonarResults = ActiveRecord::Base.connection.execute(sqlSonar).first
        defectsPerKLOC = [defectsPerKLOC, sonarResults["violations"]/(sonarResults["lines"]/1000.0)].max

      end

      @overpermission_array.push(overpermissionCount)
      @violation_array.push(defectsPerKLOC.round(0))
    end

  end
end