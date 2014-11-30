class AnalyticsController < ApplicationController

  include ActionView::Helpers::OutputSafetyHelper
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
    # Get git version information
    sqlGit = "select Count(*) AS numCommits FROM GitHistory WHERE GitHistory.appID = " + params[:id]
    @numCommits = ActiveRecord::Base.connection.execute(sqlGit).first["numCommits"]
    sqlGit = "select Count(DISTINCT author) AS numAuthors FROM GitHistory WHERE GitHistory.appID = " + params[:id]
    @numAuthors = ActiveRecord::Base.connection.execute(sqlGit).first["numAuthors"]

    # Pull app specific data
    sqlAppdata = "select * from AppData WHERE appId = " + params[:id]
    @appdata = ActiveRecord::Base.connection.execute(sqlAppdata)

    # Grab all versions for this app
    sqlVersions = "select * from Version WHERE appID = " + params[:id] + " ORDER BY build_number ASC"
    @versions = ActiveRecord::Base.connection.execute(sqlVersions)

    # Create empty arrays that will store the information used to display various graphs
    @num_overpermissions_array = Array.new
    @num_underpermissions_array = Array.new
    @androrisk_array = Array.new
    @violations_per_array = Array.new
    @complexity_per_array = Array.new
    @loc_array = Array.new

    @labels_array = Array.new
    @permission_labels_array = Array.new
    @androrisk_labels_array = Array.new
    @sonar_labels_array = Array.new

    @versions.each do |version|
      # Check if version has stowaway info
      sqlPermission = "select Count(*) as count from StowawayRun where versionID = " + version["versionID"].to_s
      hasStowaway = ActiveRecord::Base.connection.execute(sqlPermission).first["count"]

      if hasStowaway > 0
        # Get total number of overpermissions for this version
        sqlOverpermissions = "select Count(*) as num_over_permissions from OverPermission where versionID = " + version["versionID"].to_s
        numOverpermissions = ActiveRecord::Base.connection.execute(sqlOverpermissions)
        @num_overpermissions_array.push(numOverpermissions.first["num_over_permissions"])

        # Get total number of underpermissions for this version
        sqlUnderpermissions = "select Count(*) as num_under_permissions from UnderPermission where versionID = " + version["versionID"].to_s
        numUnderpermissions = ActiveRecord::Base.connection.execute(sqlUnderpermissions)
        @num_underpermissions_array.push(numUnderpermissions.first["num_under_permissions"])

        @permission_labels_array.push(version["version"].to_s)
      end

      # Get Androrisk scores
      sqlAndrorisk = "select * from Vulnerability where versionID = " + version["versionID"].to_s
      androriskScores = ActiveRecord::Base.connection.execute(sqlAndrorisk)
      # Only add if a score was found for this version
      if !androriskScores.empty?
        @androrisk_array.push((androriskScores.first["fuzzy_risk"]).round(2))
        @androrisk_labels_array.push(version["version"].to_s)
      end

      # Get num violations
      sqlSonar = "select * from CodingStandard where versionID = " + version["versionID"].to_s
      sonarResults = ActiveRecord::Base.connection.execute(sqlSonar)
      if !sonarResults.empty?
        @loc_array.push(sonarResults.first["lines"])
        @sonar_labels_array.push(version["version"].to_s)

        @violations_per_array.push( (sonarResults.first["violations"]/(sonarResults.first["lines"]/1000.0)).round(0) )
        @complexity_per_array.push( (sonarResults.first["complexity"]/(sonarResults.first["lines"]/1000.0)).round(0) )
      end

      # Get the version identifier
      @labels_array.push(version["version"].to_s)
    end

    # Get averages for shown statistics
    sqlAverage = "select COUNT(*) AS numVersions from Vulnerability"
    numVersions = ActiveRecord::Base.connection.execute(sqlAverage).first["numVersions"]
    sqlAverage = "select COUNT(*) AS numOverpermissions from OverPermission"
    @averageOverPermission = (ActiveRecord::Base.connection.execute(sqlAverage).first["numOverpermissions"] / numVersions.to_f).round(2)
    sqlAverage = "select COUNT(*) AS numUnderpermissions from UnderPermission"
    @averageUnderPermission = (ActiveRecord::Base.connection.execute(sqlAverage).first["numUnderpermissions"] / numVersions.to_f).round(2)
    sqlAverage = "select AVG(fuzzy_risk) AS averageAndrorisk from Vulnerability"
    @averageAndrorisk = ActiveRecord::Base.connection.execute(sqlAverage).first["averageAndrorisk"].round(2)
    sqlAverage = "select AVG(lines) AS averageLOC from CodingStandard"
    @averageLoc = ActiveRecord::Base.connection.execute(sqlAverage).first["averageLOC"].round(0)
    sqlAverage = "select AVG(violations) AS averageViolations from CodingStandard"
    @averageViolations = ActiveRecord::Base.connection.execute(sqlAverage).first["averageViolations"]
    @averageViolations = ( @averageViolations / (@averageLoc/1000.0) ).round(0)
    sqlAverage = "select AVG(complexity) AS averageComplexity from CodingStandard"
    @averageComplexity = ActiveRecord::Base.connection.execute(sqlAverage).first["averageComplexity"].round(0)
    @averageComplexity = ( @averageComplexity / (@averageLoc/1000.0) ).round(0)

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_versions
    sql = "select * from Version WHERE appID = " + params[:id]
    @versions = ActiveRecord::Base.connection.execute(sql)
  end

end