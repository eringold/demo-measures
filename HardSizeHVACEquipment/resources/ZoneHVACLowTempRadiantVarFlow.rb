
# open the class to add methods to return sizing values
class OpenStudio::Model::ZoneHVACLowTempRadiantVarFlow

  # Takes the values calculated by the EnergyPlus sizing routines
  # and puts them into this object model in place of the autosized fields.
  # Must have previously completed a run with sql output for this to work.
  def applySizingValues

    hydronic_tubing_length = self.autosizedHydronicTubingLength
    if hydronic_tubing_length.is_initialized
      self.setHydronicTubingLength(hydronic_tubing_length.get)
    end

    maximum_cold_water_flow = self.autosizedMaximumColdWaterFlow
    if maximum_cold_water_flow.is_initialized
      c_coil = self.coolingCoil.to_CoilCoolingLowTempRadiantVarFlow.get
      c_coil.setMaximumColdWaterFlow(maximum_cold_water_flow.get)
    end

    maximum_hot_water_flow = self.autosizedMaximumHotWaterFlow
    if maximum_hot_water_flow.is_initialized
      h_coil = self.heatingCoil.to_CoilHeatingLowTempRadiantVarFlow.get
      h_coil.setMaximumHotWaterFlow(maximum_hot_water_flow.get)
    end


  end

  # returns the autosized hydronic tubing length as an optional double
  def autosizedHydronicTubingLength

    result = OpenStudio::OptionalDouble.new()

    name = self.name.get.upcase

    model = self.model

    sql = model.sqlFile

    if sql.is_initialized
      sql = sql.get

      query = "SELECT Value
              FROM tabulardatawithstrings
              WHERE ReportName='ComponentSizingSummary'
              AND ReportForString='Entire Facility'
              AND TableName='ZoneHVAC:LowTemperatureRadiant:VariableFlow'
              AND RowName='#{name}'
              AND ColumnName='Design Size Hydronic Tubing Length'
              AND Units='m'"

      val = sql.execAndReturnFirstDouble(query)

      if val.is_initialized
        result = OpenStudio::OptionalDouble.new(val.get)
      end

    end

    return result

  end

  # returns the autosized maximum cold water flow as an optional double
  def autosizedMaximumColdWaterFlow

    result = OpenStudio::OptionalDouble.new()

    name = self.name.get.upcase

    model = self.model

    sql = model.sqlFile

    if sql.is_initialized
      sql = sql.get

      query = "SELECT Value
              FROM tabulardatawithstrings
              WHERE ReportName='ComponentSizingSummary'
              AND ReportForString='Entire Facility'
              AND TableName='ZoneHVAC:LowTemperatureRadiant:VariableFlow'
              AND RowName='#{name}'
              AND ColumnName='Design Size Maximum Cold Water Flow'
              AND Units='m3/s'"

      val = sql.execAndReturnFirstDouble(query)

      if val.is_initialized
        result = OpenStudio::OptionalDouble.new(val.get)
      end

    end

    return result

  end

 # returns the autosized hot water flow as an optional double
  def autosizedMaximumHotWaterFlow

    result = OpenStudio::OptionalDouble.new()

    name = self.name.get.upcase

    model = self.model

    sql = model.sqlFile

    if sql.is_initialized
      sql = sql.get

      query = "SELECT Value
              FROM tabulardatawithstrings
              WHERE ReportName='ComponentSizingSummary'
              AND ReportForString='Entire Facility'
              AND TableName='ZoneHVAC:LowTemperatureRadiant:VariableFlow'
              AND RowName='#{name}'
              AND ColumnName='Design Size Maximum Hot Water Flow'
              AND Units='m3/s'"

      val = sql.execAndReturnFirstDouble(query)

      if val.is_initialized
        result = OpenStudio::OptionalDouble.new(val.get)
      end

    end

    return result

  end



end
