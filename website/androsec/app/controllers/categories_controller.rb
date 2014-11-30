class CategoriesController < ApplicationController

  # GET /
  def index
    @top_categories = Array.new
    sqlCat = "select Count(*) AS count, categories from AppData GROUP BY categories ORDER BY count DESC"
    numCat = ActiveRecord::Base.connection.execute(sqlCat)

    @categories_over_permissions = Array.new
    @categories_over_permissions_count = Array.new
    @categories_count = Array.new

    @categories_androrisk = Array.new

    @categories_violations = Array.new

    # Get top 5 categories
    for i in 0..4
      @top_categories.push(numCat[i]["categories"])
      @categories_over_permissions_count.push(0)
      @categories_count.push(0)
    end

    @top_categories.each_with_index do |category, index|
      sqlEachCat = "select * from AppData where categories = '" + category + "'"
      appsForCat = ActiveRecord::Base.connection.execute(sqlEachCat)

      appsForCat.each do |app|
        # Grab all versions for this app
        sqlVersions = "select * from Version WHERE appID = " + app["appId"].to_s + " ORDER BY build_number ASC"
        versions = ActiveRecord::Base.connection.execute(sqlVersions)

        versions.each do |version|
          # Search for overpermissions
          sqlPermission = "select Count(*) as count from StowawayRun where versionID = " + version["versionID"].to_s
          hasStowaway = ActiveRecord::Base.connection.execute(sqlPermission).first["count"]

          if hasStowaway > 0
            @categories_count[index] = @categories_count[index] + 1

            sqlOverpermissions = "select Count(*) as num_over_permissions from OverPermission where versionID = " + version["versionID"].to_s
            numOverpermissions = ActiveRecord::Base.connection.execute(sqlOverpermissions).first["num_over_permissions"]

            if (numOverpermissions > 0)
              @categories_over_permissions_count[index] = @categories_over_permissions_count[index] + 1
            end
          end

        end

      end

      @categories_over_permissions.push( ((@categories_over_permissions_count[index]*1.0) / (@categories_count[index]*1.0) * 100).round(0) )

      # Get androrisk average
      sqlAndrorisk = "select AVG(fuzzy_risk) AS average from AppData JOIN Version ON AppData.appId = Version.versionID
        JOIN Vulnerability ON Version.versionID = Vulnerability.versionID WHERE AppData.categories = '" + category + "'"
      androriskAverage = ActiveRecord::Base.connection.execute(sqlAndrorisk).first["average"].round(0)
      @categories_androrisk.push(androriskAverage)

      # Get violations/kloc average
      sqlViolations = "select AVG(violations)/(AVG(ncloc)/1000) AS average from AppData JOIN Version ON AppData.appId = Version.versionID JOIN
        CodingStandard ON Version.versionID = CodingStandard.versionID WHERE AppData.categories = '" + category + "'"
      violationsAverage = ActiveRecord::Base.connection.execute(sqlViolations).first["average"].round(0)
      @categories_violations.push(violationsAverage)

    end

  end

end