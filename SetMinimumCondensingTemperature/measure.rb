#see the URL below for information on how to write OpenStudio measures
# http://openstudio.nrel.gov/openstudio-measure-writing-guide

#see the URL below for information on using life cycle cost objects in OpenStudio
# http://openstudio.nrel.gov/openstudio-life-cycle-examples

#see the URL below for access to C++ documentation on model objects (click on "model" in the main window to view model objects)
# http://openstudio.nrel.gov/sites/openstudio.nrel.gov/files/nv_data/cpp_documentation_it/model/html/namespaces.html

#start the measure
class SetMinimumCondensingTemperature < OpenStudio::Ruleset::ModelUserScript
  
  #define the name that a user will see, this method may be deprecated as
  #the display name in PAT comes from the name field in measure.xml
  def name
    return "Set Minimum Condensing Temperature"
  end
  
  #define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new

    #make a choice argument for picking the refrigeration system
    ref_sys_handles = OpenStudio::StringVector.new
    ref_sys_display_names = OpenStudio::StringVector.new

    #putting model object and names into hash
    model.getRefrigerationSystems.each do |ref_sys|
      ref_sys_display_names << ref_sys.name.to_s
      ref_sys_handles << ref_sys.handle.to_s
    end
        
    #make a choice argument for the refrigeration system to modify
    ref_sys = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("ref_sys", ref_sys_handles, ref_sys_display_names)
    ref_sys.setDisplayName("Choose a Refrigeration System to set Minimum Condensing Temperature For.")
    args << ref_sys    

    #make an argument for minimum condensing temperature
    min_cond_temp_f = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("min_cond_temp_f",true)
    min_cond_temp_f.setDisplayName("Minimum Condensing Temperature (F)")
    min_cond_temp_f.setDefaultValue(70.0)
    args << min_cond_temp_f

    return args
  end #end the arguments method

  #define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)
    
    #use the built-in error checking 
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    #assign the user inputs to variables
    ref_sys_object = runner.getOptionalWorkspaceObjectChoiceValue("ref_sys",user_arguments,model)
    min_cond_temp_f = runner.getDoubleArgumentValue("min_cond_temp_f",user_arguments)
    min_cond_temp_c = OpenStudio::convert(min_cond_temp_f,"C","F").get
    
    #check the ref_sys argument to make sure it still is in the model
    ref_sys = nil
    if ref_sys_object.empty?
      handle = runner.getStringArgumentValue("ref_sys",user_arguments)
      if handle.empty?
        runner.registerError("No refrigeration system was chosen.")
      else
        runner.registerError("The selected refrigeration system with handle '#{handle}' was not found in the model. It may have been removed by another measure.")
      end
      return false
    else
      if ref_sys_object.get.to_LightsDefinition.is_initialized
        ref_sys = ref_sys_object.get.to_RefrigerationSystem.get
      end
    end
    
    #reporting initial condition of model
    start_cond_temp_c = ref_sys.minimumCondensingTemperature
    start_cond_temp_f = OpenStudio::convert(start_cond_temp_c,"C","F").get
    runner.registerInitialCondition("#{ref_sys.name} started with a min condensing temperature of #{start_cond_temp_f}F.")
    
    #not applicable if starting temperature is same as requested temperature
    if start_cond_temp_c == min_cond_temp_c
      runner.registerAsNotApplicable("Not Applicable - system is already set at the requested minimum condensing temperature of #{min_cond_temp_f}F.")
      return true
    else
      #modify the minimum condensing temperature as requested
      ref_sys.setMinimumCondensingTemperature(min_cond_temp_c)
      runner.registerInfo("Set minimum condensing temperature of #{ref_sys.name} to #{min_cond_temp_f}F.")
    end
      
    #reporting final condition of model
    end_cond_temp_c = ref_sys.minimumCondensingTemperature
    end_cond_temp_f = OpenStudio::convert(end_cond_temp_c,"C","F").get
    runner.registerFinalCondition("#{ref_sys.name} ended with a min condensing temperature of #{end_cond_temp_f}F.")
    
    return true
 
  end #end the run method

end #end the measure

#this allows the measure to be use by the application
SetMinimumCondensingTemperature.new.registerWithApplication