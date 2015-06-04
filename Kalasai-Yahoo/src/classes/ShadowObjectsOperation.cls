/***************************************************************************
 Name 		: ShadowObjectsOperation 
 Created By : Kartik Viswanadha
 Description  : The main class to perform the Shadow Copy of the Source Objects to the Shadow Objects and vice versa via Triggers.  
 Operations:  : 
 	   This Class mainly depends on the two Custom Objects - Object Map and Field Map.
	   
	   The static fields needs to be set before calling any methods from this class are 
	   1. objectName - The name of object on which the Trigger / operation is written
	   2. isShadowObject - If the object is a Shadow Object.
	   
	   The Static Methods are 
	   1. insertShadow(Set<String> Ids) - Inserts the Shadow Records for the related Source Objects record Ids.
	   2. updateShadow(Set<String> Ids) - Updates the Shadow Records for the corresponding Source Objects record Ids
	   3. deleteShadow(Set<String> Ids) - Deletes the Shadow Records for the corresponding Source Object Record Ids.
	   4. updateSource(Set<String> Ids) - Updates the Source Records for the corresponding Shadow Object Record Ids.   
	   4. getFieldMaps() 				- The field maps are returned for the given object. 
	   
	    Private methods 	 	     	   	   
	   5. generateSoql(Set<String> ids, Boolean isSource, String whereField, String selectObject) - Generates the Dynamic SOQL from the Field Maps and Object Map. Takes in Arguments
	   	 	Ids - Set of Ids on which a Where Clause is to be Written
	   	 	isSource - boolean flags that represents if the SOQL is to be generated for Source Object Fiels or Shadow / Target Object Fields
	   	 	whereField - Currently only passing Id or Id__c 
	   	 	selectObject - Object on which the SOQL is to be dynamically populated.

****************************************************************************/

public with sharing class ShadowObjectsOperation {

	public  static String objectName;
	public  static boolean isShadowObject;
	
	
	private static boolean isChildObject = false;
	private static String copytoObjectName;
	private static String shadowParentObjectName;
	private static List<Field_Mapper__c> fieldMaps = new List<Field_Mapper__c>();
	
	
	public static String insertShadow(Set<String> ids){
			
			Set<String> shadowObjectIds	    = new Set<String>();		
			List<SObject> sourceObjects		= new List<SObject>();
			List<SObject> shadowObjects 	= new List<SObject>();
			Map<Object,String> shadowParents = new Map<Object,String>();			 	
			SObject so;			
			fieldMaps 						= ShadowObjectsOperation.getFieldMaps();			
			String whereClause = ''; 
			
			try{
				String selectSoql 				= ShadowObjectsOperation.generateSoql(ids, true, 'Id', objectname);
				sourceObjects 					= Database.query(selectSoql); // Get the source records that needs to be copied
				
				
				// Check to see if Parent Record Exists else create one. This isChildObject Field is populated when creating the Map for an Object. It is checked to see if the Object is a 
				// child object. If its a child object, the below code searches for the Parent Record to which the Child needs to be associated. 
				
				if(isChildObject){
					SObjectType shadowParentType = Schema.getGlobalDescribe().get(shadowParentObjectName);
					for(SObject s : sourceObjects){
						for(Field_Mapper__c f : fieldMaps){
							if(f.isReferenceField__c){							
								shadowObjectIds.add(String.valueof(s.get(f.Source_Field__c)));
								whereClause += '\'' + String.escapeSingleQuotes(String.valueof(s.get(f.Source_Field__c))) + '\'' + ',';
							}
								
						}
					}
				
				
					whereClause  = whereClause.substring(0,whereClause.lastIndexof(','));
					whereClause  = ' WHERE Id__c  in (' + whereClause + ')';
					
					String soql = 'SELECT Id, Id__c from ' + shadowParentObjectName + whereClause;
					for(SObject s :Database.query(soql)){
						shadowParents.put(s.get('Id__c'),s.Id);
					}				 	
				}
				
			// Get the generic type for the COPY/Target Object	
			
				SObjectType shadowType = Schema.getGlobalDescribe().get(copytoObjectName);
								
				for(SObject s : sourceObjects){				
					so = shadowType.newSObject();					 		
					for(Field_Mapper__c f : fieldMaps)
						if(f.isReferenceField__c)
							so.put(f.Target_Field__c,shadowParents.get(s.get(f.Source_Field__c)));
						else
							so.put(f.Target_Field__c,s.get(f.Source_Field__c));											
					shadowObjects.add(so);
				}
				
				insert shadowObjects; // Inserts the Shadow Objects.
				
			}catch(DMLException e){
				return e.getMessage();
			}catch(QueryException e){
				return e.getMessage();
			}
			
			return null;
			
	}
	
	// This method returns the Fields that are Mapped between the objects. Is made public for additional functionality
	public static List<Field_Mapper__c> getFieldMaps(){
		
			String whrClause;		
			Object_Mapper__c om 			= new Object_Mapper__c(); 			
					
			String soql = 'SELECT Object_Name__c, Shadow_Object_Name__c, Parent_Object__c, Shadow_Parent_Object__c, (SELECT Source_Field__c, Target_Field__c, isReferenceField__c from Field_Mappers__r) from Object_Mapper__c ';
		
			if(!isShadowObject)
				whrClause = 'WHERE Object_Name__c = ' + '\'' +String.escapeSingleQuotes(objectName) + '\'';
			else	  
				whrClause = 'WHERE Shadow_Object_Name__c = ' + '\'' +String.escapeSingleQuotes(objectName) + '\'';
				
			om = Database.query(soql + whrClause); // Get the Object Map
			
			if(!isShadowObject)
				ShadowObjectsOperation.copytoObjectName = om.Shadow_Object_Name__c; // get the Shadow Object Name
			else
				ShadowObjectsOperation.copytoObjectName = om.Object_Name__c; // get the Shadow Object Name	
			
			if(om.Parent_Object__c != null){
				isChildObject 	= true;
				shadowParentObjectName = om.Shadow_Parent_Object__c;
			}
					
			return om.Field_Mappers__r; 
			
	}
	
	// The method is used internally in the class to generate the Dynamic SOQL for the Inserts /  Updates / Deletes
	private static String generateSoql(Set<String> ids, Boolean isSource, String whereField, String selectObject){
		
		String selectClause = '';
		String whereClause  = '';
		
		for(Field_Mapper__c f:fieldMaps){
			if(isSource)
				selectClause = selectClause + f.Source_Field__c + ',';
			else	
				selectClause = selectClause + f.Target_Field__c + ',';	
		}
				
		selectClause = selectClause.substring(0,selectClause.lastIndexof(','));
				
		for(String i : ids)
			whereClause += '\'' + String.escapeSingleQuotes(i) + '\'' + ','; 
				
		whereClause  = whereClause.substring(0,whereClause.lastIndexof(','));
		whereClause  = ' WHERE ' + whereField + ' in (' + whereClause + ')';
		
		return 'SELECT ' +  selectClause + ' FROM ' + selectObject + whereClause;
			
		
	}
	
	// Update the Shadow Object Record.
	public static String updateShadow(Set<String> ids){
			
			List<SObject> shadowObjects 	= new List<SObject>();
			List<SObject> sourceObjects		= new List<SObject>();
			List<SObject> newShadowObjects 	= new List<SObject>();
			Set<String>  newShadowObjectIds = new Set<String>(); 
			fieldMaps 						= ShadowObjectsOperation.getFieldMaps();	
			SObject so;
			boolean isFound 				= false;
			
			try {
				// After getting the Mapping for the Object, get the records for the Source object.
				
				String selectSoql 	  = ShadowObjectsOperation.generateSoql(ids, true, 'Id', objectname);
				sourceObjects 		  = Database.query(selectSoql); // Get the source records that needs to be copied				
				
				// Target Objects
				
				selectSoql 	    = ShadowObjectsOperation.generateSoql(ids,false,'Id__c',copytoObjectName);
				shadowObjects	= Database.query(selectSoql);
				
				SObjectType shadowType = Schema.getGlobalDescribe().get(copytoObjectName);
				
				for(SObject s : sourceObjects){				
					// Updates the Shadow Object Records
					for(SObject t : shadowObjects){
						if(s.get('Id') == t.get('Id__c')){ // Compare the Id on the Shadow object to Id on the Source Object. This was we dont have to create a lookup on every shadow object.
							isFound = true;
							for(Field_Mapper__c f : fieldMaps){
								if(!f.isReferenceField__c)
									t.put(f.Target_Field__c,s.get(f.Source_Field__c)); 
							}
						}
					}
					// If Shadow Record Not found, inserts the records. 
					if(!isFound){						
						newShadowObjectIds.add(s.Id);
						/*so = shadowType.newSObject();					 		
						for(Field_Mapper__c f : fieldMaps)
							so.put(f.Target_Field__c,s.get(f.Source_Field__c));											
						newShadowObjects.add(so);*/
					}else
						isFound = false;											
				}
				
				update shadowObjects;				
				
				/*if(newShadowObjects.size() > 0)				
					insert newShadowObjects;*/
				if(newShadowObjectIds.size() > 0)
					insertShadow(newShadowObjectIds);	// Call the insertShadow Method with the Ids that are not found.	
				
			}catch(DMLException e){
					return e.getMessage();
			}catch(QueryException e){
					return e.getMessage();
			}
			return null;				
	}
	
	// This method updates the Source Records from the Shadow Records.
	public static String updateSource(Set<String> ids){
			
			Set<String> sourceIds = new Set<String>();				
			fieldMaps 						= ShadowObjectsOperation.getFieldMaps();	
			List<SObject> sourceObjects		= new List<SObject>();
			List<SObject> targetObjects 	= new List<SObject>(); 	
			SObject so;
			
			try {
			// After getting the Mapping for the Object, get the records for the Source object.
				
				String selectSoql 	  = ShadowObjectsOperation.generateSoql(ids, false, 'Id', objectName);
				sourceObjects		  = Database.query(selectSoql); // Get the source records that needs to be copied
				
				for(SObject s : sourceObjects){
					sourceIds.add(String.valueof(s.get('Id__c')));
				}
				
				// Target Objects
							
				selectSoql 	  = ShadowObjectsOperation.generateSoql(sourceIds, true, 'Id', copytoObjectName);
				targetObjects	= Database.query(selectSoql);
				
				for(SObject s : sourceObjects){				
					for(SObject t : targetObjects){
						if(s.get('Id__c') == t.get('Id')){
							for(Field_Mapper__c f : fieldMaps){
								if(f.Source_Field__c != 'Id' && !f.isReferenceField__c) // Cannot really copy the Id or the reference fields.
									t.put(f.Source_Field__c,s.get(f.Target_Field__c));
							}
						}
					}					
				}
				
				update targetObjects;
				
			}catch(DMLException e){
				return e.getMessage();
			}catch(QueryException e){
				return e.getMessage();
			}
			return null;
	}
	
	// This method is used to delete the Shadow Records for corresponding source object records.
	public static String deleteShadow(Set<String> ids){

			List<SObject> shadowObjects 	= new List<SObject>(); 	
			SObject so;
						
			fieldMaps 		 = ShadowObjectsOperation.getFieldMaps(); 

			try {
			// After getting the Mapping for the Object, get the records for the Source object.
								
				String selectSoql 	  = ShadowObjectsOperation.generateSoql(ids, true, 'Id', objectName);
				List<SObject> objects = Database.query(selectSoql); // Get the source records that needs to be copied
				
				selectSoql 	  	= ShadowObjectsOperation.generateSoql(ids, false, 'Id__c', copytoObjectName);
				shadowObjects	= Database.query(selectSoql);
				
				if(shadowObjects.size() > 0)			
					delete shadowObjects;
				
			}catch(DMLException e){
				return e.getMessage();
			}catch(QueryException e){
				return e.getMessage();
			}
			return null;
	}
	
}