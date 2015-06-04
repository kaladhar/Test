public with sharing class caAuctionTriggerHandler{
	
	//Auction Trigger Handler method
	public static void caAuctionTrigger(List<Auction__c> newAuctions, Map<ID,Auction__c> oldAuctionMap,Boolean bisAfter,Boolean bisUpdate){
		 if (bisAfter && bisUpdate)
 {

 	map<String,Double> aggrSumBidAmountMap = new map<String,Double>();
 	list<User> lstUserstoUpdate =  new list<User>();
 	set<String> setHighestBidders = new set<String>();
 	
 	
 	
 	// Loop through the list of Auctions and see if there is a change in Bid Amount, Auction Status or Highest Bidder. If so, add the Bidder to the Users to be updated.
 	for(Auction__c oAuctionRec : newAuctions){
 		if((oAuctionRec.Bid_Amount__c != oldAuctionMap.get(oAuctionRec.Id).Bid_Amount__c) || (oAuctionRec.auction_status__c != oldAuctionMap.get(oAuctionRec.Id).auction_status__c) 
 		      || (oAuctionRec.High_Bidder__c != oldAuctionMap.get(oAuctionRec.Id).High_Bidder__c)){
 			if(oAuctionRec.High_Bidder__c != null)
 			setHighestBidders.add(oAuctionRec.High_Bidder__c);
 		}
 	}
 	
 	// Get the Sum of Bid Amount for each Bidder in the Set
 	AggregateResult[] aggrSumBidAmount = [Select High_Bidder__c,SUM(Bid_Amount__c) BidSum
 	                               From Auction__c 
 	                               Where auction_status__c='Active' and 
 	                                     High_Bidder__c in:setHighestBidders 
 	                               Group By High_Bidder__c ];
 	
 	// Map the Sum of Bid Amount into Map that will be used to update the Bid Amount for each user                               
 	for(AggregateResult eachaggrSumBidAmount : aggrSumBidAmount){
 		aggrSumBidAmountMap.put(String.valueOf(eachaggrSumBidAmount.get('High_Bidder__c')),Decimal.valueOf(String.valueOf(eachaggrSumBidAmount.get('BidSum'))));	
 	}
 	
 	if(setHighestBidders.size() > 0){
 		lstUserstoUpdate = [Select id,Winning_Bid_Amount__c from user where id in:setHighestBidders];
 		for(User oUser : lstUserstoUpdate){
 			if(aggrSumBidAmountMap.containsKey(oUser.Id)){
 			 oUser.Winning_Bid_Amount__c = aggrSumBidAmountMap.get(oUser.Id);
 			}
 		}
 	}
 	
 	update lstUserstoUpdate;
 	
	}
	}
 

 }