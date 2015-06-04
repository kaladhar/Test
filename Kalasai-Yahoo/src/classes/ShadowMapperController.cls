/***************************************************************************
 Name       : ShadowMapperController 
 Created By : Kartik Viswanadha
 Description  : The Controller class for the ShadowMapper Visualforce Page.
 Operations:  : 
       This page allows users to Select a Object and its corresponding Shadow Object and Map fields between them.
       The mapping is stored in Custom Object Object Mapper and fields in its Child Object Field Mapper.
       The controller class also has ability to auto match the fields on the Field Labels. And also gives User to select the fields Manually.   
       Only one map is allowed to be created for one object, if you want to change the Map for the object, delete the Map and re-create it.   

****************************************************************************/

public with sharing class ShadowMapperController {

    private List<SelectOption> objectsList;
    private List<SelectOption> fieldsList;
    private Map<String, Schema.SobjectField> Mapobject;
    private Map<String, String> fieldValueLabels    = new Map<String, String>();
    private Set<String> inaccessibleNames           = new Set<String>();
    private Map<String,String> fieldLabelNames1;
    private Map<String,String> fieldLabelNames2;
    private Map<String,String> objectMaps;
    private List<String> destFields;
    private String parentObjectName;
    private String shadowParentObjectName;
    private String parentFieldName;
    private String shadowParentFieldName;
    
    public String selectedObject1   {get;set;}
    public String selectedObject2   {get;set;}
    public String selectedField     {get;set;}
    public String filterValue       {get;set;}
    public Integer deleteCount      {get;set;}
    public List<wrapFields> wfields {get;set;}
    public String xmlInput          {get;set;}
    public String mapName           {get;set;}
    public String httpMethod        {get;set;}
    public String serviceURL        {get;set;}
    public boolean isCustomValue    {get;set;}
    public boolean isTestAllowed    {get;set;}
    
    public boolean isObjectSelected;
    public boolean isAutomatchSelected;
    public Integer numberoffields = 0;
    
    // Constructor class
    public ShadowMapperController(Apexpages.StandardController con){
        
        wfields = new List<wrapFields>();
        isObjectSelected = false;
        isCustomValue    = false; 
        isTestAllowed    = false;
        isAutomatchSelected = false;        
        init();
    }
    
    
    // This method gets all the Objects using GlobalDescribe.
    
    private void init(){

         objectsList = new List<SelectOption>();  
         objectMaps = new Map<String,String>();     
         
         Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
         Set<String> objectKeys = gd.keySet();
         for(String objectKey: objectKeys) {              
             Schema.SobjectType sobjecttype = gd.get(objectKey);
             Schema.DescribeSObjectResult r = sobjecttype.getDescribe();
             if(r.isAccessible() && r.isCreateable()){                                                 
                 objectMaps.put(r.getName(),r.getLabel());                                  
             }            
       }

    }

    // This method builds the Mapper fields from the Selected Objects. 
    public Pagereference buildMappers(){
        
        if(selectedObject1 != null && selectedObject2 != null){
            isObjectSelected = true;                
            getObjectFields(); //
            
            wfields = new List<wrapFields>();       
            wrapFields w;
        
            if(fieldLabelNames1.size() > 0){            
                for(String f : fieldLabelNames1.values()){
                    w = new wrapFields();
                    wfields.add(w); // Empty Wrapper Class is created with size equal to number of fields in the Source Object 
                }
            }
            
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Select both the Objects '));
        }

        return null;
    }
    
    
    // This method inserts the Map into Object Mapper and Field Mapper Custom Objects
    public Pagereference createMaps(){
            
            Object_Mapper__c om               = new Object_Mapper__c();
            List<Field_Mapper__c> fieldMaps   = new List<Field_Mapper__c>();        
            Savepoint s1;                               
            om.Object_Name__c         = selectedObject1;
            om.Shadow_Object_Name__c  = selectedObject2;
            om.Parent_Object__c       = parentObjectName; // if the Object has a Parent Object add it to the record.
            om.Shadow_Parent_Object__c  = shadowParentObjectName;
    
            try{
                insert om;              
            }catch(DMLException e){             
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Map failed to create - ' + e.getMessage()));
                return null;
            }
            
            Field_Mapper__c fm;
            
            for(wrapFields wf : wfields){
            
                if(wf.sourceField != null && wf.targetField != null ){
                    fm = new Field_Mapper__c();
                    
                    fm.Object_Mapper__c = om.Id;
                    fm.Source_Field__c  = wf.sourceField;
                    fm.Target_Field__c  = wf.targetField;                           
                    fieldMaps.add(fm);
                }
            }
            
            try {
                    fieldMaps.add(new Field_Mapper__c(Object_Mapper__c = om.Id,Source_Field__c='Id',Target_Field__c='Id__c')); // Add Id field by default, its required to have an ID Custom Field on all the Shadow Objects
                if(parentFieldName != null && shadowParentFieldName != null)
                    fieldMaps.add(new Field_Mapper__c(Object_Mapper__c = om.Id,Source_Field__c=parentFieldName,Target_Field__c=shadowParentFieldName,isReferenceField__c=true)); // If the Object is a Child Object, add the Parent Field Reference.
                insert fieldMaps;
            }catch(DMLException e){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Map failed to create - ' + e.getMessage()));
                 Database.rollback(s1); // Rollback to the SavePoint
                 return null;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Map Created'));
            isTestAllowed = true;       
            return null;
    }
    
    // Method Resets to the Original State.
    public Pagereference reset(){
        
        wfields = new List<wrapFields>();
        isObjectSelected = false;
        isCustomValue    = false; 
        isTestAllowed    = false;
        isAutomatchSelected = false;                
        init();
        return null;
    }   
    
    
    // This methods performs Auto matching of fields between the two objects based on the field labels.
    public Pagereference autoMatch(){
        
        isAutomatchSelected = true;
        wfields = new List<wrapFields>();       
        wrapFields w;
        
        
        if(fieldLabelNames1.size() > 0 && fieldLabelNames2.size() > 0){
            
            for(String s : fieldLabelNames1.keyset()){
                for(String t :fieldLabelNames2.keyset()){
                    if(fieldLabelNames1.get(s) == fieldLabelNames2.get(t)){
                        w = new wrapFields();
                        w.sourceField = s;
                        w.targetField = t;
                        wfields.add(w);                     
                    }                       
                }               
            }
        
            if(wfields.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to do Auto Matching - Try doing manual Mapping '));                
            }

        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No Fields in either of objects '));
        }       
        return null;        
    }
    
    
    // This method gets the all the fields for the selected Objects.
    public void getObjectFields(){
        
       fieldLabelNames1 = new Map<String,String>();
       fieldLabelNames2 = new Map<String,String>();
       
       if (selectedObject1 != null && selectedObject2 != null) {            
           
           Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
           Set<String> objectKeys = gd.keySet();
           
           for(String objectKey: objectKeys) {
            
            if (objectKey == selectedObject1) {            
                
                Schema.SobjectType sobjecttype = gd.get(objectKey);
                Schema.DescribeSObjectResult r = sobjecttype.getDescribe();
                
                MapObject = r.fields.getMap();

                for(String s: MapObject.keyset()) {
                    
                     Schema.SobjectField so = MapObject.get(s);
                     DescribeFieldResult f = so.getDescribe();                                                                   
                     
                  //if(f.isAccessible()&& f.isUpdateable())  // Checks to see if the field is accessible and updateable. Can be expanded to add more validations.    
                   if(f.isAccessible())                                               
                         fieldLabelNames1.put(f.getName(),f.getlabel()); 
                    if(f.getRelationshipOrder() == 0){ // This Checks if the Field is a Reference to a Parent Object. 
                        List<Schema.Sobjecttype> parentObjects = f.getReferenceTo();
                        parentObjectName                       = parentObjects[0].getDescribe().getName();  
                        parentFieldName                        = f.getName();                       
                     }                                              
                                                                                            
                }
          }else if(objectKey == selectedObject2){
                
                Schema.SobjectType sobjecttype = gd.get(objectKey);
                Schema.DescribeSObjectResult r = sobjecttype.getDescribe();
                
                MapObject = r.fields.getMap();

                for(String s: MapObject.keyset()) {
                    
                     Schema.SobjectField so = MapObject.get(s);
                     DescribeFieldResult f = so.getDescribe();                                                                   
                     
                     if(f.isAccessible() && f.isUpdateable())                                                       
                         fieldLabelNames2.put(f.getName(),f.getlabel());
                     
                     if(f.getRelationshipOrder() == 0){
                        List<Schema.Sobjecttype> parentObjects = f.getReferenceTo();
                        shadowParentObjectName                 = parentObjects[0].getDescribe().getName();
                        shadowparentFieldName                          = f.getName();                           
                     }                                                                      
                }
                    
          }
        }   
      }     
    }

    // Getter for Boolean isObjectSelected
    public boolean getisObjectSelected(){
        return isObjectSelected;
    }
    // Getter for Boolean isAutomatchSelected
    public boolean getisAutomatchSelected(){
        return isAutomatchSelected;
    }
    // Getter for the SourceObject Selection
    public List<SelectOption> getObjects(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Select Source Object--'));
        List<String> sorted = new List<String>();
        sorted.addAll(objectMaps.keyset());
        sorted.sort();
        for(String s :sorted){
            if(!s.contains('Shadow')) // Filter the Shadow Objects from the List. Can be expanded to filter more types.
                options.add(new SelectOption(s,objectMaps.get(s)));
        }
        return options;
    }
    // Getter for the Shadow Object Selection
    public List<SelectOption> getShadowObjects(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Select Target Object--'));
        for(String s : objectMaps.keyset()){
            if(s.contains('__c') && s.contains('Shadow')) // Filter to select only the Shadow Objects. Can be Expanded
                options.add(new SelectOption(s,objectMaps.get(s)));
        }
        return options;
    }
    
    // Getter for the Source Object Fields.
    public List<SelectOption> getFields(){
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Select Source Field--'));
        
        for(String s: fieldLabelNames1.keySet()){
            options.add(new SelectOption(s,fieldLabelNames1.get(s)));
        }
        
        return options;
    }
    // Getter for the Shadow Object Fields
    public List<SelectOption> gettargetFields(){
        

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Select Target Field--'));
        
        for(String s: fieldLabelNames2.keySet()){
            options.add(new SelectOption(s,fieldLabelNames2.get(s)));
        }
        
        return options;
    }
    
    // Wrapper Class to Wrap the fields together. This is used to display the fields as tables. Can be expanded to add any boolean flags, Data Types.
    public class wrapFields{
    
        public String sourceField{get;set;}
        public String targetField{get;set;}
        

    }
        

    

}