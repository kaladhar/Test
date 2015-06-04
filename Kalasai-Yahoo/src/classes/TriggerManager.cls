/***************************************************************************
 Name 		: TriggerManager 
 Created By : Kartik Viswanadha
 Description  : Manage the Trigger Execution 
 Operations:  : This class manages the Trigger executions. Used to make sure that there are no Trigger Recursion Issues when dealing with Forward / Return Triggers.
 				For every trigger created. this class has 
 				
 				static boolean variable - which is by default set to false
 				hasalreadyran{object}Trigger - returns the static variable
 				setalreadyran{object}Trigger - sets the boolean variable to true
 				setNotran{object}Trigger 	 - sets the boolean variable to false 
 	    

****************************************************************************/

public with sharing class TriggerManager {

	private static boolean ranSourceTrigger = false;
	private static boolean ranShadowTrigger = false;

	public static boolean hasalreadySourceTrigger(){
        return ranSourceTrigger;
    }
    
    public static void setalreadyRanSourceTrigger(){
        ranSourceTrigger = true;
    }
    
    public static void setNotRanSourceTrigger(){
        ranSourceTrigger = false;
    }
    
    public static boolean hasalreadyRanShadowTrigger(){
        return ranShadowTrigger;
    }
    
    public static void setalreadyRanShadowTrigger(){
        ranShadowTrigger = true;
    }
    
    public static void setNotRanShadowTrigger(){
        ranShadowTrigger = false;
    }
  }