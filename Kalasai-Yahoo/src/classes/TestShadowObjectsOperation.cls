/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=false)
private class TestShadowObjectsOperation {

    static testMethod void shadowObjectsOperationMethod() {
        
        // Create the Map first . Not relying on the Data in the Org.
        Object_Mapper__c om = new Object_Mapper__c();        
        Apexpages.StandardController con = new Apexpages.StandardController(om);
        ShadowMapperController testpage  = new ShadowMapperController(con);
        
        testpage.selectedObject1 = 'Opportunity';
        testpage.selectedObject2 = 'Shadow_Opportunity__c';
        
        testpage.buildMappers();        
        testpage.autoMatch();        
        testpage.createMaps();
        
        
        Object_Mapper__c om2 = new Object_Mapper__c();        
        Apexpages.StandardController con2 = new Apexpages.StandardController(om2);
        ShadowMapperController testpage2  = new ShadowMapperController(con2);
        
        testpage2.selectedObject1 = 'PSS_Product__c';
        testpage2.selectedObject2 = 'Shadow_PSS_Product__c';
        
        testpage2.buildMappers();        
        testpage2.autoMatch();        
        testpage2.createMaps();
        
        
        
        List<Opportunity> ops = new List<Opportunity>();
         
        Opportunity o;
       	
       	// Insert the Opportunities -  Triggers Insert Method on ShadowObjectsOperation.insertShadow() 
        for(Integer i=0;i<200;i++){
		   	o = new Opportunity();
		    o.Name = 'Test Opportunity ' + i;
		    o.Description = 'Testing the Opportunity ' + i;
		   // o.ExpectedRevenue = 1000.00;
		    o.CloseDate = Date.valueof(system.now() + 3);
		    o.NextStep = 'Call ' + i;
		    o.IsPrivate = false;
		    o.Probability = 80;
		    o.TotalOpportunityQuantity = 1000;
		    o.StageName = 'Prospecting';
		    o.Type = 'New Customer';
		    ops.add(o);
		 }
		 
		Test.StartTest(); 
        insert ops;
        
        
        List<Shadow_Opportunity__c> sops = new List<Shadow_Opportunity__c>();
        sops = [SELECT Id from Shadow_Opportunity__c where Name LIKE 'Test %'];
        
        system.debug(sops.size());
        system.assertEquals(200,sops.size());
        
        // Update the Opportunities - Triggers update Method on ShadowObjectsOperation.updateShadow()
        TriggerManager.setNotRanSourceTrigger();
        TriggerManager.setNotRanShadowTrigger();
        
        Integer i = 0;
        for(Opportunity op : ops){
        	i+=1;
        	op.Name = 'Updated Name ' + i;
        }
		
		update ops;
		
		
		sops = new List<Shadow_Opportunity__c>();
		sops = [SELECT Id,Name from Shadow_Opportunity__c where Name LIKE 'Updated %'];
        
        system.debug(sops.size());
        system.assertEquals(200,sops.size());
        
        
        // Update the Shadow Opportunities - Triggers update Method on ShadowObjectsOperation.updateSource()
        TriggerManager.setNotRanSourceTrigger();
        TriggerManager.setNotRanShadowTrigger();
        
        Integer j=0;
        for(Shadow_Opportunity__c so : sops){
        	j += 1;
        	so.Name = 'Updated from Shadow ' + j;
        }
        
        
        	update sops;
        
        
        ops = new List<Opportunity>();
        ops = [SELECT Id, Name from Opportunity where Name like 'Updated from Shadow%'];
        system.debug(ops.size());
        system.assertEquals(200,ops.size());
        
        
         // Insert the Child Records for Opportunities
        
        TriggerManager.setNotRanSourceTrigger();
        TriggerManager.setNotRanShadowTrigger();
        
        List<PSS_Product__c> pssProducts = new List<PSS_Product__c>();
         
        PSS_Product__c p;
        
        for(Integer k=0;k<200;k++){
        	p = new PSS_Product__c();
        	p.Name = 'Test Child for Opportunity ' + k;
        	p.Opportunity__c = ops[k].Id;
        	pssProducts.add(p);
        }
        
        
        	insert pssProducts;
        
        
        
        List<Shadow_PSS_Product__c> spss = new List<Shadow_PSS_Product__c>();
        spss = [SELECT Id, Name from Shadow_PSS_Product__c where Name like 'Test Child for %'];
        system.debug(spss.size());
        system.assertEquals(200,spss.size());
        
        
        TriggerManager.setNotRanSourceTrigger();
        TriggerManager.setNotRanShadowTrigger();
        
        i = 0;
        for(PSS_Product__c p1 :pssProducts){
        	i +=1;
        	p1.Name = 'Updated Child Name ' + i;
        }
        
       
        	update pssProducts;
       	
        
        spss = new List<Shadow_PSS_Product__c>();
        
        spss = [SELECT Id, Name from Shadow_PSS_Product__c where Name like 'Updated Child Name %'];
        system.debug(spss.size());
        system.assertEquals(200,spss.size());
        
        
        TriggerManager.setNotRanSourceTrigger();
        TriggerManager.setNotRanShadowTrigger();
        
        j = 0;
        For(Shadow_PSS_Product__c sp : spss){
        	j += 1;
        	sp.Name = 'Update from Child Shadow' + j;
        }
        
        
        	update spss;
        
        
        pssProducts = new List<PSS_Product__c>();
        pssProducts = [SELECT Id, Name from PSS_Product__c where Name like 'Update from Child%'];
        system.debug(pssProducts.size());
        system.assertEquals(200,pssProducts.size());
        
        // Delete the Child Records - Triggers the delete Method on the ShadowObjectsOperation.deleteShadow()
        
        TriggerManager.setNotRanSourceTrigger();
        TriggerManager.setNotRanShadowTrigger();
        
        
        	delete pssProducts;
        
        
        spss = [SELECT Id, Name from Shadow_PSS_Product__c where Name like 'Update from Child Shadow %'];
        system.debug(spss.size());
        system.assertEquals(0,spss.size());
        
        
        
        // Delete the Opportunities - Triggers the delete Method on the ShadowObjectsOperation.deleteShadow()
        
        TriggerManager.setNotRanSourceTrigger();
        TriggerManager.setNotRanShadowTrigger();
        
        
        	delete ops;
        Test.stopTest();	
        
        sops = new List<Shadow_Opportunity__c>();
        sops = [SELECT Id from Shadow_Opportunity__c where Name LIKE 'Updated %'];
        
        system.debug(sops.size());
        system.assertEquals(0,sops.size());
        
        
 	       
    }
}