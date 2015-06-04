public with sharing class caAuctionDetailsController {
    public Bid__c oBid {get;set;}   
 public Auction__c oAuctionRec {get;set;}
 public Boolean BiddingAllowed {get;set;} 
 
 public caAuctionDetailsController(ApexPages.StandardController stdController){
  BiddingAllowed = false;
  oAuctionRec = (Auction__c)stdController.getRecord();
  if(oAuctionRec != null){
      getDetails();
      
      if(oAuctionRec.Bids__r.size() == 0){                
          oBid = new Bid__c();
          oBid.Auction__c = oAuctionRec.Id;
      }
      else{
        oBid = oAuctionRec.Bids__r[0];
      }
      
      User u = [Select id,name,profile.name from user where id=:userinfo.getUserId()];
      if(oAuctionRec.Auction_Status__c == 'Active'){
                if(u.profile.name == 'Charity Auctions Consumer' && String.valueOf((oAuctionRec.ownerId)).substring(0,15) != String.valueOf((userinfo.getUserId())).substring(0,15))
                    BiddingAllowed = true;
              }
    }
 }
 
 private void getDetails(){
    oAuctionRec = [Select id,Name,Bid_Amount__c,Declared_Value__c,
                      Reserve_Amount__c,Auction_Status__c,Registered_Charity__c,High_Bidder__c,
                      OwnerId,Description__c,
                      (select id,Bid_Amount__c From Bids__r Where ownerId = :userInfo.getUserId()) 
               From Auction__c 
               Where id=:oAuctionRec.Id limit 1];
       }
  
 public pagereference placeBid(){
  try{
    if(oBid.Bid_Amount__c != oAuctionRec.Bid_Amount__c){
        upsert oBid;
        getDetails();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Bid successfully placed/updated.'));
    }
  }
  catch(Exception ex){
    String errMsg = ex.getMessage();
    if(!errMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
    }
  }
  
  return null;
 }
 
}