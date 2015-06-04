public with sharing class caAuctionController {
    
    public User oUser {get;set;}
    
    public Auction__c oAuctionRec {get;set;}
    public Boolean bEditMode {get;set;}
    public Boolean bEditAllowed{get;set;}
    public Boolean bStartAuctionAllowed {get;set;}
    public Boolean bEndAuctionAllowed {get;set;}
    private ApexPages.StandardController stdCont;
    public caAuctionController(ApexPages.StandardController stdController){
        this.stdCont = stdController; 
        this.oAuctionRec = (Auction__c)stdCont.getRecord();
        init();
    }
    
    private void init(){
        beditMode = false;
  bEditAllowed = false;
  bStartAuctionAllowed = false;
  bEndAuctionAllowed = false;
  
        System.debug('Kala --> oAuctionRec.Id:' + oAuctionRec.Id);
     
  if(this.oAuctionRec.Id != null){
   beditMode = true;
  this.oAuctionRec = [Select id,Name,Registered_Charity__c,Declared_Value__c,
                      Reserve_Amount__c,Auction_Status__c,High_Bidder__c,
                      OwnerId,Bid_Amount__c,Description__c 
               From Auction__c 
               Where id=:oAuctionRec.Id limit 1]; 
  }
  else{
   this.oAuctionRec.Auction_Status__c = 'New';
  }
      
  if(this.oAuctionRec.Auction_Status__c == 'New'){
   bStartAuctionAllowed = true;
  }
  else if(this.oAuctionRec.Auction_Status__c == 'Active'){
   bEndAuctionAllowed = true;
  }
  
  oUser = [Select Id,Name,Profile.Name 
           From User 
           Where id=: userinfo.getUserId()];
  
  if(this.oAuctionRec != null && this.oAuctionRec.OwnerId != null){
   if(this.oAuctionRec.OwnerId == oUser.Id || oUser.Profile.Name == 'Charity Auctions Administrator'){
    bEditAllowed = true;
   }
  }
    }
    
    public pagereference startAuction(){
        try{
            this.oAuctionRec.Auction_Status__c = 'Active';
            // stdCont.save();
      upsert oAuctionRec;
      init();
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
         for(Bid__c oBid : [Select Id,Auction__r.Registered_Charity__r.OwnerId From Bid__c Where Auction__c =: oAuctionRec.Id limit 1]){
            bidFound = true;
            if(oBid.Auction__r.Registered_Charity__c != null){
             registerdCharityOwnerId = oBid.Auction__r.Registered_Charity__r.OwnerId;
            }
         }
            
            if(!bidFound){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Auction can\'t be ended. No bid exists'));
                bCanEnd = false;
            }
            else if(oAuctionRec.Reserve_Amount__c != null && oAuctionRec.Reserve_Amount__c > oAuctionRec.Bid_Amount__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Auction can\'t be ended. Bid amount is less than reserve amount'));
    bCanEnd = false;
            }
            else if(oAuctionRec.OwnerId != oUser.Id && oUser.Profile.Name != 'Charity Auctions Administrator' && registerdCharityOwnerId != oUser.Id){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Auction can\'t be ended. Insufficient privileges'));
    bCanEnd = false;
            }
                                    
            if(bCanEnd){
          oAuctionRec.Auction_Status__c = 'Ended';
          return stdCont.save();
          //update oAuctionRec;
          //init();
            }
        }
        catch(Exception ex ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
  
  return null;
 }
    
}