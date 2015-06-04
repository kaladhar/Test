public with sharing class StoreFront {
    public String message { get; set; }

	
	// Define the Shop method
	public PageReference shop() {
message = 'You bought: ';
for (DisplayMerchandise p: products) {
if (p.count > 0) {
message += p.merchandise.name + ' (' + p.count + ') ';
}
}
return null;
}

// Define the DisplayMerchandise inner class
DisplayMerchandise[] products;
public class DisplayMerchandise {
	//declare a variable merchandise of type Merchandise__c - Merchandise object
public Merchandise__c merchandise { get; set; }
public Decimal count { get; set; }
//Method to pass the Merchandise object and initialize the class
public DisplayMerchandise(Merchandise__c item) {
this.merchandise = item;
}
}

// Method to fetch the products
public DisplayMerchandise[] getProducts() {
if (products == null) {
	//Create the array of DisplayMerchandise class
products = new DisplayMerchandise[]{};
//Fetch each product and add it to the array of DisplayMerchandise class
for (Merchandise__c item :
[SELECT id, name, description__c, price__c
FROM Merchandise__c
WHERE TotalInventory__c > 0]) {
products.add(new DisplayMerchandise(item));
}
}
//Return the products just fetched
return products;
}



}