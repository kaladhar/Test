public with sharing class AuctionController {
	
	public User oUser {get;set;}
	
	public Auction__c oAuction {get;set;}
	public Boolean bEdit {get;set;}
	public Boolean bCanEdit{get;set;}
	public Boolean bCanStartAuction {get;set;}
	public Boolean bCanEndAuction {get;set;}
	private ApexPages.StandardController stdCont;
	public AuctionController(ApexPages.StandardController stdController){
		stdCont = stdController;
		oAuction = (Auction__c)stdController.getRecord();
		init();
	}
	
	private void init(){
		bEdit = false;
  bCanEdit = false;
  bCanStartAuction = false;
  bCanEndAuction = false;
  
		System.debug('Sarath --> oAuction.Id:' + oAuction.Id);
     
  if(oAuction.Id != null){
   bEdit = true;
   oAuction = [Select id,Name,Registered_Charity__c,Declared_Value__c,
                      Reserve_Amount__c,Auction_Status__c,High_Bidder__c,
                      OwnerId,Bid_Amount__c,Description__c 
               From Auction__c 
               Where id=:oAuction.Id limit 1];
  }
  else{
   oAuction.Auction_Status__c = 'New';
  }
      
  if(oAuction.Auction_Status__c == 'New'){
   bCanStartAuction = true;
  }
  else if(oAuction.Auction_Status__c == 'Active'){
   bCanEndAuction = true;
  }
  
  oUser = [Select Id,Name,Profile.Name 
           From User 
           Where id=: userinfo.getUserId()];
  
  if(oAuction != null && oAuction.OwnerId != null){
   if(oAuction.OwnerId == oUser.Id || oUser.Profile.Name == 'Charity Auctions Administrator'){
    bCanEdit = true;
   }
  }
	}
	
	public pagereference startAuction(){
		try{
			oAuction.Auction_Status__c = 'Active';
			return stdCont.save();
	  //upsert oAuction;
	  //init();
		}
		catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
		return null;
	}
	
	public pagereference endAuction(){
		try{
			Boolean bCanEnd = true;
		 Boolean bidFound = false;
		 Id registerdCharityOwnerId = null;
		 for(Bid__c oBid : [Select Id,Auction__r.Registered_Charity__r.OwnerId From Bid__c Where Auction__c =: oAuction.Id limit 1]){
		 	bidFound = true;
		 	if(oBid.Auction__r.Registered_Charity__c != null){
		 	 registerdCharityOwnerId = oBid.Auction__r.Registered_Charity__r.OwnerId;
		 	}
		 }
			
			if(!bidFound){
			 	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Auction can\'t be ended. No bid exists'));
			 	bCanEnd = false;
			}
			else if(oAuction.Reserve_Amount__c != null && oAuction.Reserve_Amount__c > oAuction.Bid_Amount__c){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Auction can\'t be ended. Bid amount is less than reserve amount'));
    bCanEnd = false;
			}
			else if(oAuction.OwnerId != oUser.Id && oUser.Profile.Name != 'Charity Auctions Administrator' && registerdCharityOwnerId != oUser.Id){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Auction can\'t be ended. Insufficient privileges'));
    bCanEnd = false;
			}
									
			if(bCanEnd){
		  oAuction.Auction_Status__c = 'Ended';
		  return stdCont.save();
		  //update oAuction;
		  //init();
			}
		}
		catch(Exception ex ){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
  
  return null;
 }
	
	/*public String accId;
	public Boolean newRec {get;set;}
	
	public AuctionController(ApexPages.StandardController stdController){
		newRec = true;
		accId = apexpages.currentPage().getParameters().get('id');
		if(accId != null || accId != '')newRec = false;
	}
	public pagereference startAuction(){
		Auction__c act = new Auction__c();
		if(accId != null || accId != ''){
			try{
				act  =  [Select id,Name,Registered_Charity__c,Declared_Value__c,
                       Reserve_Amount__c,Auction_Status__c,High_Bidder__c,
                       OwnerId,Bid_Amount__c,Description__c 
                From Auction__c 
                Where id=:auctionId limit 1];
				act.Auction_Status__c = 'Active';
				update act;
				PageReference pageRef = new PageReference('/'+act.Id);
		 		pageRef.setRedirect(true);
		 		return pageRef;
			}catch(exception e){
				Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.error,e.getMessage()));
			}
		}
		return null;
	}*/
}