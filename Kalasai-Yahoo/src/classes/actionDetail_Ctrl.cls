public without sharing class actionDetail_Ctrl {
	public String accId;
	public Boolean canBeEnded {get;set;}
	public Boolean addBid {get;set;}
	public Auction__c act {get;set;}
	public String bidAmount {get;set;}
	
	public actionDetail_Ctrl(ApexPages.StandardController stdController){
		canBeEnded = false;
		addBid = false;
		accId = apexpages.currentPage().getParameters().get('id');
		if(accId != null && accId != ''){
			act  = [Select id,Auction_Status__c,Registered_Charity__r.OwnerId,ownerId,Bid_Amount__c from Auction__c where id=:accId limit 1];
			bidAmount = String.valueOf(act.Bid_Amount__c);
			validateAuction();
			validateNewBid();
			system.debug('---addBid----'+addBid);
		}
	}
	public pagereference endAuction(){
		if(act != null){
			try{
				act.Auction_Status__c = 'Ended';
				update act;
				PageReference pageRef = new PageReference('/'+act.Id);
		 		pageRef.setRedirect(true);
		 		return pageRef;
			}catch(exception e){
				Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.error,e.getMessage()));
			}
		}
		return null;
	}
	public void validateAuction(){
		list<Bid__c> bidsList = new list<Bid__c>(); 
		bidsList = [Select id from Bid__c where Auction__c=:accId];
		User u = [Select id,name,profile.name from user where id=:userinfo.getUserId()];
		if(bidsList.size()>0 && act.Auction_Status__c == 'Active'){
			if(u.profile.name == 'Charity Auctions Administrator')
				canBeEnded = true;
			if(u.profile.name == 'Charity Auctions Charity' && String.valueOf((act.Registered_Charity__r.OwnerId)).substring(0,15) == String.valueOf((userinfo.getUserId())).substring(0,15))
				canBeEnded = true;
			if(u.profile.name == 'Charity Auctions Consumer' && String.valueOf((act.ownerId)).substring(0,15) == String.valueOf((userinfo.getUserId())).substring(0,15))
				canBeEnded = true;
		}
	}
	public void validateNewBid(){
		User u = [Select id,name,profile.name from user where id=:userinfo.getUserId()];
		if(act.Auction_Status__c == 'Active'){
			if(u.profile.name == 'Charity Auctions Consumer' && String.valueOf((act.ownerId)).substring(0,15) != String.valueOf((userinfo.getUserId())).substring(0,15))
				addBid = true;
		}
	}
	public pagereference placeUpdateBid(){
		list<Bid__c> bdList = new list<Bid__c>();
		try{
			bdList = [Select id,Auction__c,Bid_Amount__c from Bid__c where Auction__c=:accId limit 1];
			if(bdList.size()>0){
				bdList[0].Bid_Amount__c = Decimal.valueOf(bidAmount);
				update bdList[0];
			}
			else{
				Bid__c bd = new Bid__c();
				bd.Auction__c = accId;
				bd.Bid_Amount__c = Decimal.valueOf(bidAmount);
				insert bd;
			}
			PageReference pageRef = new PageReference('/'+act.Id);
	 		pageRef.setRedirect(true);
	 		return pageRef;
		}
		catch(exception e){
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.error,e.getMessage()));
			return null;
		}
		return null;
	}

}