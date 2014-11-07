module HomeHelper
  def getTotal
    sql = "Select COUNT(*) from Version;"
    sqlReturn = ActiveRecord::Base.connection.execute(sql)
  end
end
