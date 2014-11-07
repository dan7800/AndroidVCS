class HomeController < ApplicationController
  # GET /
  def index
    @versions = Version.all
    @appDatas = Appdata.all
    @numVersions = Version.all.size
    @codingStandards = CodingStandard.all
  end

end