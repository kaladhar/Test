///**********************************************************************************/
///
///  (c) 2009,2010 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/


var batchGeocoding = new BatchGeocoding();
var clearGeocodeStatus = new ClearGeocodeStatus();

/////////////////////////////////////////////////////////////////////////////////////
// BatchGeocoding
/////////////////////////////////////////////////////////////////////////////////////
function BatchGeocoding()
{
	var geocoder;
    var fieldNames;
    var objectName;
    var objectLabel;
    var addressPrefix;
    var sObjects;
    var batchIndex;
    var totalRecords;
    var totalCompleted;
    var statusCallback;
    var abortCallback;
    var completionCallback;
    var queryResult;
    var firstBatchFetched;
var iterator;    
    
	this.createGeocoder = function()
	{
		if (!util.isDefined(this.geocoder))
		{
			this.geocoder = new GClientGeocoder();
		}
	};

	this.start = function(objectName, objectLabel, addressPrefix, statusCallback, 
		abortCallback, completionCallback)
	{
		this.objectName = objectName;
		this.objectLabel = objectLabel;
		this.addressPrefix = addressPrefix;
		this.statusCallback = statusCallback;
		this.abortCallback = abortCallback;
		this.completionCallback = completionCallback;
				
		this.initFieldNames();		

		this.createGeocoder();

		this.totalRecords = this.getObjectCount();
		
		if (this.totalRecords == 0)
		{
			this.setStatusText(locale.noItemsToGeocode);
			this.setCompletionStatus();
			return;
		}

		this.setStatusText(locale.initializing);

	   	this.firstBatchFetched = false;
		this.totalCompleted = 0;
		this.geocodeNextBatch();
	};

	this.getObjectCount = function()
	{
	    try
	    {
			var queryString = "SELECT Count() FROM " + this.objectName +
				" WHERE " + this.fieldNames.geocodeStatusField + " = null " + 
	    		(this.objectName == "Lead" ? "AND IsConverted = false " : "");
		
			var queryResult = sforce.connection.query(queryString);
			return queryResult.size;
	    } 
	    catch(error)
	    {
	        alert("Fetch count failed with error: " + error);
	    }

        return 0;
	};
	
	this.fetchRecords = function()
	{
		if (!this.firstBatchFetched)
		{
			this.fetchFirstBatch();
			return true;
		}	

//		if (this.queryResult.done == "false")
if (this.iterator.hasNext())
		{
			this.fetchNextBatch();
			return true;
		}
		
		return false;
	};
	
	this.fetchFirstBatch = function()
	{
	    this.sObjects = [];
	    var queryString;

		//sforce.debug.trace = true;
	
	    try
	    {
			sforce.connection.batchSize = 200;
			sforce.connection.batchSizeSpecified = true;

	    	queryString = "SELECT Id, " + 
	    		this.fieldNames.streetField + ", " +
	    		this.fieldNames.cityField + ", " +
	    		this.fieldNames.stateField + ", " +
	    		this.fieldNames.postalCodeField + ", " +
	    		this.fieldNames.countryField + ", " +
	    		this.fieldNames.geocodeAddressField + ", " +
	    		this.fieldNames.geocodeAccuracyField + ", " +
	    		this.fieldNames.geocodeStatusField + ", " +
	    		this.fieldNames.latitudeField + ", " +
	    		this.fieldNames.longitudeField + 
	    		" FROM " + this.objectName + " WHERE " + 
	    		this.fieldNames.geocodeStatusField + " = null " + 
	    		(this.objectName == "Lead" ? "AND IsConverted = false " : "");
	    		
	        this.queryResult = sforce.connection.query(queryString);
/*
	        this.sObjects = this.queryResult.getArray('records');
*/

this.iterator = new sforce.QueryResultIterator(this.queryResult);
for (var i = 0; i < 200 && this.iterator.hasNext(); i++)
{
	this.sObjects.push(this.iterator.next());
}
	        
 			this.setRecordAddresses();

		    this.firstBatchFetched = true;
	    } 
	    catch(error)
	    {
	        alert("Fetch " + this.objectName + " failed with error: " + error);
	    }
	};
	
	this.fetchNextBatch = function()
	{
		this.sObjects.length = 0;	
	
		try
		{
/*
			this.queryResult = sforce.connection.queryMore(this.queryResult.queryLocator);
			this.sObjects = this.queryResult.getArray('records');
*/
for (var i = 0; i < 200 && this.iterator.hasNext(); i++)
{
	this.sObjects.push(this.iterator.next());
}
			
			this.setRecordAddresses();
		}
	    catch(error)
	    {
	        alert("Fetch next " + this.objectName + " batch failed with error: " + error);
	    }
	};
	
	this.setRecordAddresses = function()
	{
        for (var i = 0; i < this.sObjects.length; i++)
        {
        	eval("var street = this.sObjects[i]." + this.fieldNames.streetField);
        	eval("var city = this.sObjects[i]." + this.fieldNames.cityField);
        	eval("var state = this.sObjects[i]." + this.fieldNames.stateField);
        	eval("var postalCode = this.sObjects[i]." + this.fieldNames.postalCodeField);
        	eval("var country = this.sObjects[i]." + this.fieldNames.countryField);
        	var address = this.getAddressString(street, city, state, postalCode, country);

			eval("this.sObjects[i]." + this.fieldNames.geocodeAddressField + " = address");
        }
	};
	
	this.updatePreviousBatch = function() 
	{
		if (this.sObjects == null || this.sObjects.length == 0)
		{
			return;
		}

		var updateArray = this.sObjects;
		
		eval("var geocodeStatus = this.sObjects[this.sObjects.length-1]." + this.fieldNames.geocodeStatusField);
		
		if (geocodeStatus == null || geocodeStatus.length == 0)
		{
			var updateCount = 0;
			for ( ; updateCount < this.sObjects.length; updateCount++)
			{
				eval("geocodeStatus = this.sObjects[updateCount]." + this.fieldNames.geocodeStatusField);
				if (geocodeStatus == null || geocodeStatus.length == 0)
				{
					break;
				}	
			}

			updateArray = this.sObjects.splice(0, updateCount);
		}
		
	    try
	    {
	    	sforce.connection.update(updateArray);	
	    } 
	    catch(error)
	    {
	        alert("Update " + this.objectName + " failed with error: " + error);
	        return;
	    }
	};

	this.processNextBatch = function()
	{
		this.batchIndex = 0;
		this.geocodeNextObject();
	};

	this.geocodeNextBatch = function()
	{
		this.updatePreviousBatch();
		
		if (this.fetchRecords())
		{
			this.processNextBatch();
		}
		else
		{
			this.cleanUp();			
			this.setCompletionStatus();
		}		
	};
	
	this.geocodeNextObject = function()
	{
		try
		{
			eval("var address = this.sObjects[this.batchIndex]." + this.fieldNames.geocodeAddressField);
			this.geocoder.getLocations(address, this.processGeocode);
		}
		catch(error)
		{
			alert("Geocode Next Object failed with error: " + error);
			this.abortGeocoding();
		}			
	};

	this.processGeocode = function(response)
	{
		batchGeocoding.processResponse(response);
	};

	this.processResponse = function(response)
	{
		try
		{
			if (response.Status.code == 620)
			{
				setTimeout("batchGeocoding.geocodeNextObject()", 250);
				return;
			}
	
			eval("this.sObjects[this.batchIndex]." + this.fieldNames.geocodeStatusField + " = this.convertResponseCode(response.Status.code)");

			if (response.Status.code == 200)
			{	
				var latitude = response.Placemark[0].Point.coordinates[1];
				var longitude = response.Placemark[0].Point.coordinates[0];
				var geocodeAccuracy = response.Placemark[0].AddressDetails.Accuracy;
				var geocodeAddress = response.Placemark[0].address.replace(/"/gi, "'"); 
							
				eval("this.sObjects[this.batchIndex]." + this.fieldNames.latitudeField + " = latitude");
				eval("this.sObjects[this.batchIndex]." + this.fieldNames.longitudeField + " = longitude");
				eval("this.sObjects[this.batchIndex]." + this.fieldNames.geocodeAccuracyField + " = geocodeAccuracy");
				eval("this.sObjects[this.batchIndex]." + this.fieldNames.geocodeAddressField + " = geocodeAddress");
			}
			else
			{
				eval("this.sObjects[this.batchIndex]." + this.fieldNames.geocodeAddressField + " = ''");
			}

			++this.totalCompleted;
			
			var pctComplete = String(parseInt(String(this.totalCompleted * 100 / this.totalRecords)));
			var statusText = locale.processed;
			statusText = statusText.replace("{0}", String(this.totalCompleted));
			statusText = statusText.replace("{1}", String(this.totalRecords));
			statusText = statusText.replace("{2}", pctComplete);

			// debug output
			//statusText += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + this.sObjects[this.batchIndex].Id + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			//eval("statusText += util.escapeString(this.sObjects[this.batchIndex]." + this.fieldNames.geocodeAddressField + ")");


			this.setStatusText(statusText);

			eval("var abort = " + this.abortCallback + "()");
		
			if (abort)
			{
				this.abortGeocoding();			
				return;
			}
		
			++this.batchIndex;

			if (this.batchIndex >= this.sObjects.length)
			{
				this.geocodeNextBatch();	
			}
			else
			{
				setTimeout("batchGeocoding.geocodeNextObject()", 50);
			}
		}
		catch(error)
		{
			alert("Process Geocode Response failed with error: " + error);
			this.abortGeocoding();
		}			
	};
	
	this.abortGeocoding = function()
	{
		this.updatePreviousBatch();			
		this.cleanUp();			
	};

	this.cleanUp = function()
	{
		if (util.isDefined(this.sObjects))
		{
			this.sObjects.length = 0;
			this.sObjects = null;
		}
	};

	this.setCompletionStatus = function()
	{
		eval(this.completionCallback + "()");
	};

	this.convertResponseCode = function(code)
	{
		switch(code)
		{
			case 200:
				return "G_GEO_SUCCESS";
			default:			
			case 400:
				return "G_GEO_BAD_REQUEST";
			case 500:
				return "G_GEO_SERVER_ERROR";
			case 601:
				return "G_GEO_MISSING_ADDRESS";
			case 602:
				return "G_GEO_UNKNOWN_ADDRESS";
			case 603:
				return "G_GEO_UNAVAILABLE_ADDRESS";
			case 604:
				return "G_GEO_UNKNOWN_DIRECTIONS";
			case 610:
				return "G_GEO_BAD_KEY";
			case 620:
				return "G_GEO_TOO_MANY_QUERIES";
		}
	};
	
	this.getAddressString = function(street, city, state, postalCode, country)
	{
		var addressString = "";

   		if (street == null)
   		{
   			return addressString;
   		}
   		else
   		{
   			addressString += street;
   		}

   		if (city != null)
   		{
   			addressString += "," + city;
   		}

       	if (state != null && street != null && city != null)
       	{ 
           	addressString += "," + state;
       	}
        	
       	if (postalCode != null)
       	{ 
           	addressString += "," + postalCode;
       	}
        	
       	if (country != null)
       	{
       		addressString += "," + country;
       	}
			     	
       	return addressString;
	};

	this.getIsCustomObject = function()
	{
		return (this.objectName != "Account" &&
			this.objectName != "Lead" && this.objectName != "Contact");
	};

	this.initFieldNames = function()
	{
		if (this.getIsCustomObject())
		{
			this.initCustomObjectFieldNames();
			return;
		}
			
		this.fieldNames = {};
		
		this.fieldNames.streetField = this.addressPrefix + "Street";		
		this.fieldNames.cityField = this.addressPrefix + "City";
		this.fieldNames.stateField = this.addressPrefix + "State";		
		this.fieldNames.postalCodeField = this.addressPrefix + "PostalCode";		
		this.fieldNames.countryField = this.addressPrefix + "Country";
		
		this.addressPrefix = (this.objectName == "Account" ? this.addressPrefix + "_" : "");
		
		this.fieldNames.geocodeStatusField = "pexmaps__" + this.addressPrefix + "Geocode_Status__c";		
		this.fieldNames.geocodeAddressField = "pexmaps__" + this.addressPrefix + "Geocode_Address__c";		
		this.fieldNames.geocodeAccuracyField = "pexmaps__" + this.addressPrefix + "Geocode_Accuracy__c";		
		this.fieldNames.latitudeField = "pexmaps__" + this.addressPrefix + "Latitude__c";		
		this.fieldNames.longitudeField = "pexmaps__" + this.addressPrefix + "Longitude__c";		
	};

	this.initCustomObjectFieldNames = function()
	{
		var queryString;
		var queryResult;	
		var records;
	
	    try
	    {
			queryString = "SELECT pexmaps__StreetField__c, pexmaps__CityField__c, " +
				"pexmaps__StateField__c, pexmaps__PostalCodeField__c, pexmaps__CountryField__c, " +
				"pexmaps__GeocodeStatusField__c, pexmaps__GeocodeAddressField__c, " +
				"pexmaps__GeocodeAccuracyField__c, pexmaps__LatitudeField__c, " +
				"pexmaps__LongitudeField__c FROM pexmaps__TerritoryCustomObject__c " +
				"WHERE Name = '" + this.objectName + "'";
		
			queryResult = sforce.connection.query(queryString);
	        records = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Custom Object fields failed with error: " + error);
	    }

		if (records.length == 0)
		{
			return;
		}
		
		this.fieldNames = {};
		
		this.fieldNames.streetField = records[0].pexmaps__StreetField__c;		
		this.fieldNames.cityField = records[0].pexmaps__CityField__c;
		this.fieldNames.stateField = records[0].pexmaps__StateField__c;
		this.fieldNames.postalCodeField = records[0].pexmaps__PostalCodeField__c;	
		this.fieldNames.countryField = records[0].pexmaps__CountryField__c;
		this.fieldNames.geocodeStatusField = records[0].pexmaps__GeocodeStatusField__c;	
		this.fieldNames.geocodeAddressField = records[0].pexmaps__GeocodeAddressField__c;	
		this.fieldNames.geocodeAccuracyField = records[0].pexmaps__GeocodeAccuracyField__c;	
		this.fieldNames.latitudeField = records[0].pexmaps__LatitudeField__c;		
		this.fieldNames.longitudeField = records[0].pexmaps__LongitudeField__c;		
	};

	this.setStatusText = function(statusText)
	{
		eval(this.statusCallback + "('" + statusText + "')");
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// ClearGeocodeStatus
/////////////////////////////////////////////////////////////////////////////////////
function ClearGeocodeStatus()
{
    var geocodeStatusFieldName;
    var objectName;
    var objectLabel;
    var addressPrefix;
    var statusCallback;
    var completionCallback;
    var sObjects;
    var batchIndex;
    var totalRecords;
    var totalCompleted;
    
   	this.usingManualGeocodes = true;
    
    this.start = function(objectName, objectLabel, addressPrefix, 
    	statusCallback, completionCallback)
    {
		this.objectName = objectName;
		this.objectLabel = objectLabel;
		this.addressPrefix = addressPrefix;
		this.statusCallback = statusCallback;
		this.completionCallback = completionCallback;
				
		this.initGeocodeStatusFieldName();		

		this.totalRecords = this.getObjectCount();
		
		if (this.totalRecords == 0)
		{
			this.setStatusText(locale.geocodeStatusAlreadyCleared);
			this.setCompletionStatus();
			return;
		}
		
	    this.totalCompleted = 0;
		this.clearGeocodes();

		this.setCompletionStatus();
    };
    
    this.setUsingManualGeocodes = function()
    {
	    try
	    {
			sforce.connection.query("SELECT Manual_Geocode__c FROM " + this.objectName + " LIMIT 1");
	    } 
	    catch(error)
	    {
	        this.usingManualGeocodes = false;
	    }
    };
    
 	this.getObjectCount = function()
	{
		this.setUsingManualGeocodes();	

	    try
	    {
			var queryString = "SELECT Count() FROM " + this.objectName +
				" WHERE " + this.geocodeStatusFieldName + " != null " + 
				(this.usingManualGeocodes ? "AND Manual_Geocode__c = false " : "") +
	    		(this.objectName == "Lead" ? "AND IsConverted = false " : "");
		
			var queryResult = sforce.connection.query(queryString);
			return queryResult.size;
	    } 
	    catch(error)
	    {
	        alert("Fetch count failed with error: " + error);
	    }

        return 0;
	};

	this.updateBatch = function(sObjects)
	{
	    try
	    {
	    	sforce.connection.update(sObjects);	
	    } 
	    catch(error)
	    {
	        alert("Update " + this.objectName + " failed with error: " + error);
	    }
	};

 	this.clearGeocodes = function()
	{
	    var sObjects = [];
	    var queryString;
	    var queryResult;

	    try
	    {
	    	queryString = "SELECT Id, " + this.geocodeStatusFieldName + 
		    	" FROM " + this.objectName + 
				" WHERE " + this.geocodeStatusFieldName + " != null " + 
				(this.usingManualGeocodes ? "AND Manual_Geocode__c = false " : "") +
	    		(this.objectName == "Lead" ? "AND IsConverted = false " : "");
	    		
	        queryResult = sforce.connection.query(queryString);
	        
	        
	        
	        
 			iterator = new sforce.QueryResultIterator(queryResult);
 			
 			while (iterator.hasNext())
 			{
 				sObjects.length = 0;
 				
	 			for (var i = 0; i < 200 && iterator.hasNext(); i++)
 				{
 					sObjects.push(iterator.next());	
		        	eval("sObjects[i]." + this.geocodeStatusFieldName + " = null");
 				}
 				
				this.updateBatch(sObjects);
			
				this.totalCompleted += sObjects.length;

				var pctComplete = parseInt(String(this.totalCompleted * 100 / this.totalRecords));
				var statusText = locale.geocodeStatusReset;
				statusText = statusText.replace("{0}", String(this.totalCompleted));
				statusText = statusText.replace("{1}", String(this.totalRecords));
				statusText = statusText.replace("{2}", String(this.objectLabel));
				statusText = statusText.replace("{3}", String(pctComplete));

				this.setStatusText(statusText);
 			}
 			
	    } 
	    catch(error)
	    {
	        alert("Clear geocodes " + this.objectName + " failed with error: " + error);
	        return;
	    }
	};


 /*
 	this.clearGeocodes = function()
	{
	    var sObjects = [];
	    var queryString;
	    var queryResult;
	    var moreRecords = true;

	    try
	    {
			sforce.connection.batchSize = 200;
			sforce.connection.batchSizeSpecified = true;

	    	queryString = "SELECT Id, " + this.geocodeStatusFieldName + 
		    	" FROM " + this.objectName + 
				" WHERE " + this.geocodeStatusFieldName + " != null " + 
				(this.usingManualGeocodes ? "AND Manual_Geocode__c = false " : "") +
	    		(this.objectName == "Lead" ? "AND IsConverted = false " : "");
	    		
	        queryResult = sforce.connection.query(queryString);
	        sObjects = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch " + this.objectName + " failed with error: " + error);
	        return;
	    }

	    while (moreRecords)
	    {
	        for (var i = 0; i < sObjects.length; i++)
	        {
	        	eval("sObjects[i]." + this.geocodeStatusFieldName + " = null");
	        }

			this.updateBatch(sObjects);
			
			this.totalCompleted += sObjects.length;

			var pctComplete = parseInt(String(this.totalCompleted * 100 / this.totalRecords));
			var statusText = locale.geocodeStatusReset;
			statusText = statusText.replace("{0}", String(this.totalCompleted));
			statusText = statusText.replace("{1}", String(this.totalRecords));
			statusText = statusText.replace("{2}", String(this.objectLabel));
			statusText = statusText.replace("{3}", String(pctComplete));

			this.setStatusText(statusText);
	
			if (queryResult.done == "true")
			{
				moreRecords = false;
			}
			else
			{
				try
				{
					queryResult = sforce.connection.queryMore(queryResult.queryLocator);
					sObjects = queryResult.getArray('records');
				}
			    catch(error)
			    {
			        alert("Fetch " + this.objectName + " failed with error: " + error);
	    		    return;
			    }
			}
		}
	};
 */
	this.getIsCustomObject = function()
	{
		return (this.objectName != "Account" &&
			this.objectName != "Lead" && this.objectName != "Contact");
	};
 
 	this.initGeocodeStatusFieldName = function()
	{
		if (this.getIsCustomObject())
		{
			this.initCustomObjectGeocodeStatusFieldName();
			return;
		}
			
		this.addressPrefix = (this.objectName == "Account" ? this.addressPrefix + "_" : "");
		this.geocodeStatusFieldName = "pexmaps__" + this.addressPrefix + "Geocode_Status__c";		
	};

	this.initCustomObjectGeocodeStatusFieldName = function()
	{
		var queryString;
		var queryResult;	
		var records;
	
	    try
	    {
			queryString = "SELECT pexmaps__GeocodeStatusField__c FROM pexmaps__TerritoryCustomObject__c " +
				"WHERE Name = '" + this.objectName + "'";
		
			queryResult = sforce.connection.query(queryString);
	        records = queryResult.getArray('records');
	    } 
	    catch(error)
	    {
	        alert("Fetch Custom Object fields failed with error: " + error);
	    }

		if (records.length == 0)
		{
			return;
		}
		
		this.geocodeStatusFieldName = records[0].pexmaps__GeocodeStatusField__c;	
	};

	this.setStatusText = function(statusText)
	{
		eval(this.statusCallback + "('" + statusText + "')");
	};

	this.setCompletionStatus = function()
	{
		eval(this.completionCallback + "()");
	};
}