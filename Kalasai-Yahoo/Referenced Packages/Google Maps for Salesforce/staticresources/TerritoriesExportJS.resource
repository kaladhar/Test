///**********************************************************************************/
///
///  (c) 2009,2010 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/

var exports = new Exports();

/////////////////////////////////////////////////////////////////////////////////////
// Export
/////////////////////////////////////////////////////////////////////////////////////
function Exports()
{
	//var EXPORT_REQUEST_URL = "http://localhost:8888/pexmapsdataprocessor";
	var EXPORT_REQUEST_URL = "https://pexmapsdataproc.appspot.com/pexmapsdataprocessor";
	
	var exportFormat;
	var requestForm;
	var requestFormDataInput;
	var requestDocNameInput;
	var requestFormatInput;
	var requestOutlinesInput;
	var requestTripInput;
	var requestBoundsInput;
	var showFullDetails;
	var reqData = "";

	var minLat = 91.0;
	var maxLat = -91.0;
	var minLng = 181.0;
	var maxLng = -181.0;
	
	var objectIndex = [];
	objectIndex["accounts"] = "0";
	objectIndex["leads"] = "1";
	objectIndex["contacts"] = "2";
	objectIndex["customObjects"] = "3";
	objectIndex["customLocations"] = "4";
	objectIndex["users"] = "5";


	this.requestExport = function(format, exportTrip)
	{
		
		this.setupFields();

		showFullDetails = document.getElementById("check_KmlShowFullDetails").checked;

		exportFormat = format;
		requestFormatInput.value = format;

		var requestGenerated = exportTrip ? this.generateTripRequest() : this.generateViewRequest();
		 
		if (requestGenerated)
		{
			this.sendRequest();
		}
	};

	this.setupFields = function()
	{
		requestForm = document.getElementById("form_ExportRequest");
		requestForm.action = EXPORT_REQUEST_URL;
		requestFormDataInput = document.getElementById("input_Export");
		requestDocNameInput = document.getElementById("input_ExportDocName");
		requestFormatInput = document.getElementById("input_ExportFormat");
		requestOutlinesInput = document.getElementById("input_ExportOutlines");
		requestTripInput = document.getElementById("input_ExportTrip");
		requestBoundsInput = document.getElementById("input_ExportBounds");
	};

	this.generateTripRequest = function()
	{
		requestDocNameInput.value = trip.name;

		var tripMapObjects = this.getTripMapObjects("Account");
		this.generateViewObjectsRequest("accounts", tripMapObjects);

		tripMapObjects = this.getTripMapObjects("Lead");
		this.generateViewObjectsRequest("leads", tripMapObjects);

		tripMapObjects = this.getTripMapObjects("Contact");
		this.generateViewObjectsRequest("contacts", tripMapObjects);

		tripMapObjects = this.getTripMapObjects("Custom Object");
		this.generateViewObjectsRequest("customObjects", tripMapObjects);

		tripMapObjects = this.getTripMapObjects("Custom Location");
		this.generateViewObjectsRequest("customLocations", tripMapObjects);

		tripMapObjects = this.getTripMapObjects("User");
		this.generateViewObjectsRequest("users", tripMapObjects);

		if (!this.verifyRequestLength())
		{
			reqData = "";
			return false;
		}		

		requestFormDataInput.value = reqData;
		reqData = "";
		
		if (exportFormat == "gpx")
		{
			requestBoundsInput.value = this.generateBounds();

			this.generateTripRouteRequest();

			if (!this.verifyRequestLength())
			{
				reqData = "";
				requestFormDataInput.value = "";
				return false;
			}		

			requestTripInput.value = reqData;
			reqData = "";
		}

		return true;
	};

	this.getTripMapObjects = function(mapObjectType)
	{
		var tripMapObjects = [];
		for (var i = 0; i < trip.waypoints.length; i++)
		{
			if (trip.waypoints[i].mapObject.type == mapObjectType)
			{
				tripMapObjects.push(trip.waypoints[i].mapObject);
			}
		}

		return tripMapObjects;
	};

	this.generateViewRequest = function()
	{
		requestDocNameInput.value = territories.view.name;

		this.generateViewObjectsRequest("accounts", territories.view.accounts);
		this.generateViewObjectsRequest("leads", territories.view.leads);
		this.generateViewObjectsRequest("contacts", territories.view.contacts);
		this.generateViewObjectsRequest("customObjects", territories.view.customObjects);
		this.generateViewObjectsRequest("customLocations", territories.view.customLocations);
		this.generateViewObjectsRequest("users", territories.view.users);

		if (!this.verifyRequestLength())
		{
			reqData = "";
			return false;
		}		

		requestFormDataInput.value = reqData;
		reqData = "";

		if (exportFormat == "kml")
		{
			this.generateOutlinesRequest();

			if (!this.verifyRequestLength())
			{
				reqData = "";
				requestFormDataInput.value = "";
				return false;
			}		

			requestOutlinesInput.value = reqData;
			reqData = "";
		}

		if (exportFormat == "gpx")
		{
			requestBoundsInput.value = this.generateBounds();
		}
		
		return true;
	};

	this.verifyRequestLength = function()
	{
		if (requestFormDataInput.value.length + reqData.length > 125000)
		{
			alert("Request is too large. Reduce the number of items mapped.");
			return false;			
		}
		
		return true;
	}

	this.generateViewObjectsRequest = function(objectType, viewObjects)
	{
		for (var i = 0; i < viewObjects.length; i++)
		{
			if (exportFormat == "kml")
			{
				this.generateMapObjectForKml(objectType, viewObjects[i]);
			}
			else if (exportFormat == "gpx")
			{
				this.generateMapObjectForGpx(objectType, viewObjects[i]);
			}
			else if (exportFormat == "csv")
			{
				this.generateMapObjectForCsv(objectType, viewObjects[i]);
			}
		}
	};

	this.generateMapObjectForCsv = function(objectType, mapObject)
	{
		var isCustomLocation = objectType == "customLocations";
		var isUser = objectType == "users";
		var isAccount = objectType == "accounts";
		var isContact = objectType == "contacts";
		var isLead = objectType == "leads";
		var isParent = isAccount || isContact || isLead;
		
		eval("var typeIndex = objectIndex['" + objectType + "'];");
		var lat = mapObject.address.coordinates.lat();
		var lng = mapObject.address.coordinates.lng();
		
		reqData += reqData.length > 0 ? separator.currency : "";
		reqData += util.replaceDoubleQuotesWithSingleQuotes(mapObject.name) + separator.para + 
			mapObject.id + separator.para + typeIndex + separator.para + 
			mapObject.address.getAddressString() + separator.para + 
			lat + separator.para + lng + separator.para;
   		reqData += (!isCustomLocation && !isUser ?  mapObject.getRawDisplayFieldsData() : "0") + separator.para;
		reqData += isParent ?  mapObject.getRawChildObjectsData(false) : "0";
	};

	this.generateMapObjectForKml = function(objectType, mapObject)
	{
		var isCustomLocation = objectType == "customLocations";
		var isUser = objectType == "users";
		var isAccount = objectType == "accounts";
		var isContact = objectType == "contacts";
		var isLead = objectType == "leads";
		var isParent = isAccount || isContact || isLead;
		
		eval("var iconFile = objectIndex['" + objectType + "'];");
		var infoHtml = isCustomLocation && mapObject.draggable ? mapObject.info + "<br/>" : mapObject.address.getAddressHtml();
		var lat = mapObject.address.coordinates.lat();
		var lng = mapObject.address.coordinates.lng();
		
		reqData += reqData.length > 0 ? separator.currency : "";
		reqData += util.escapeString(mapObject.name) + separator.para + mapObject.id + separator.para + iconFile + separator.para + infoHtml + separator.para + lng + separator.para + lat + separator.para;
   		reqData += (isCustomLocation ? "0" : util.getSalesforceServer()) + separator.para;
   		reqData += (!isCustomLocation && !isUser && showFullDetails ? mapObject.getRawDisplayFieldsData() : "0") + separator.para;
		reqData += isParent && showFullDetails ? mapObject.getRawChildObjectsData(true) : "0";
	};
	
	this.generateOutlinesRequest = function()
	{
		for (var i = 0; i < outlines.outlines.length; i++)
		{
			this.generateOutlineRequest(outlines.outlines[i]);
		}

		for (var i = 0; i < outlines.readOnlyOutlines.length; i++)
		{
			this.generateOutlineRequest(outlines.readOnlyOutlines[i]);
		}
	};
		
	this.generateOutlineRequest = function(outline)
	{
		var poly = outline.polyline;
		var options = this.getOutlineOptions(outline);

		reqData += (reqData.length > 0 ? separator.currency : "");

		reqData += outline.name + separator.para;
		reqData += outline.info + separator.para;
		reqData += options.lineColor + separator.para;
		reqData += options.lineWidth + separator.para;
		reqData += (outline.type != "polyline" ? options.fillColor : "") + separator.para;
			
		for (var j = 0; j < poly.getVertexCount(); j++)
		{
			reqData += poly.getVertex(j).lng();
			reqData += ",";
			reqData += poly.getVertex(j).lat();
			reqData += ",0 ";
		}
	};	
		
	this.getOutlineOptions = function(outline)
	{
		var lineOpacity = (Math.round(Number(outline.options.borderOpacity) * 256)).toString(16);
		var lineColor = outline.options.borderColor;
		lineColor = lineOpacity + lineColor.slice(5) + lineColor.slice(3, 5) + lineColor.slice(1, 3);
		var fillOpacity = (Math.round(Number(outline.options.fillOpacity) * 256)).toString(16);
		var fillColor = outline.options.fillColor;
		fillColor = fillOpacity + fillColor.slice(5) + fillColor.slice(3, 5) + fillColor.slice(1, 3);
		
		return { 
			lineColor : lineColor,
			lineWidth : outline.options.borderWeight,
			fillColor : fillColor };
	};

	this.generateMapObjectForGpx = function(objectType, mapObject)
	{
		var isCustomLocation = objectType == "customLocations";
		
		var infoHtml = isCustomLocation && mapObject.draggable ? mapObject.info : mapObject.address.getAddressString();
		var lat = mapObject.address.coordinates.lat();
		var lng = mapObject.address.coordinates.lng();

		minLat = lat < minLat ? lat : minLat;
		maxLat = lat > maxLat ? lat : maxLat;
		minLng = lng < minLng ? lng : minLng;
		maxLng = lng > maxLng ? lng : maxLng;
		
		reqData += reqData.length > 0 ? separator.currency : "";
		reqData += mapObject.name + separator.para + infoHtml + separator.para + lng + separator.para + lat;
	};

	this.generateBounds = function()
	{
		return minLat + separator.para + minLng + separator.para + maxLat + separator.para + maxLng; 
	};
	
	
	this.generateTripRouteRequest = function()
	{
		if(!trip.started)
		{
			return;
		}
		
		var numRoutes = trip.directions.getNumRoutes(); 
		
		if (numRoutes == 0)
		{
			return;
		}
		
		for (var i = 0; i < numRoutes; i++)
		{
			var route = trip.directions.getRoute(i);
			var numSteps = route.getNumSteps();
			
			for (var j = 0; j < numSteps; j++)
			{
				var stepLatLng = route.getStep(j).getLatLng();
				
				if (reqData.length > 0)
				{
					reqData += separator.para;
				}
				
				reqData += stepLatLng.lat() + separator.para + stepLatLng.lng(); 
			}
		}
		
		var endLatLng = trip.directions.getRoute(numRoutes - 1).getEndLatLng();
		reqData += separator.para + endLatLng.lat() + separator.para + endLatLng.lng(); 
	};
	
	this.sendRequest = function()
	{
		requestForm.submit();
	};
}
