///**********************************************************************************/
///
///  (c) 2009,2010 Pexys, Inc.
///  The javascript code in this file is the property of Pexys, Inc.
///  No right is implied or granted to copy or reuse the code in any way
///  or for any purposes.
///
///**********************************************************************************/

var outlines = new Outlines();


/////////////////////////////////////////////////////////////////////////////////////
// Outline
/////////////////////////////////////////////////////////////////////////////////////
function Outline()
{
	this.originalOptions = null;
	this.originalName = "";
	this.originalInfo = "";
	
	this.editingOutline = false;
	this.editInputMode = false;

	this.init = function(polyline, type, options, name, info, readOnly)
	{
		this.polyline = polyline;
		this.type = type;
		this.options = options;
		this.name = name;
		this.info = info;
		this.readOnly = readOnly;
	};
	
	this.getHtml = function()
	{
		var html = "<div>";
			
		if (browserInfo.isMSIE() && browserInfo.version() < 8)
		{
			html += "<table width='223px' cellspacing='0' cellpadding='0' border='0'><tr><td>";
		}
		else
		{
			html += "<table width='100%' cellspacing='0' cellpadding='0' border='0'><tr><td>";
		}
		
		html += "<div>";
		
		html += "<b>" + this.name + "</b><br/>";

		html += "<div style='max-height:75px; max-width: 240px; overflow-y:hidden'>" + this.info + "</div>";

		html += "<div><hr style='height:1px;border-width:0;color:gainsboro;background-color:gainsboro'/></div>";
		
		if (this.type == "circle")
		{
			html += this.getDisplayText() + "<br/>";
		}
		
		if (this.type == "polyline")
		{
			var meters = this.polyline.getLength();
			var kilometers = (Math.round(meters / 10) / 100);
			var miles = Math.round((meters / 1000) * 62.1371192) / 100; 
			
			html += "<b>Distance:</b>&nbsp;" + util.formatNumber(kilometers, 2) + " km (" + util.formatNumber(miles, 2) + " mi)";
		}
		else if (this.type == "polygon" || this.type == "circle")
		{
			var squareMeters = this.polyline.getArea();
			var squareKilometers = Math.round(squareMeters / 10000) / 100;
			var squareMiles = Math.round((squareMeters / 1000000) * 38.6102159) / 100;
			
			html += "<b>" + locale.area + ":</b>&nbsp;" + util.formatNumber(squareKilometers, 2) + " km<sup>2</sup> (" + util.formatNumber(squareMiles, 2) + " mi<sup>2</sup>)";
		}
		html += "</div>";
		
		if (this.editingOutline)
		{
			html += "<div><hr style='height:1px;border-width:0;color:gainsboro;background-color:gainsboro'/></div>";
			html += "<a style='color:blue' href='javascript:outlines.selectedOutline.switchToEditInputMode(map.getInfoWindow().getPoint());'>" + locale.edit + "</a>";
			html += "<a style='color:blue;margin-left:7px' href='javascript:outlines.selectedOutline.switchToSaveTemplateMode();'>" + locale.saveAsTemplate + "</a>";
			html += "<a style='color:blue;margin-left:7px' href='javascript:map.closeInfoWindow();outlines.removeSelectedOutline();'>" + locale.remove + "</a>";
		}
		
		html += "</td></tr></table><div>";
		
		return html;
	};
	
	this.getEditHtml = function()
	{
		var textLimit = "255";
		var limitTextLengthJavascript = "if(this.value.length&gt;" + textLimit + ")this.value=this.value.substring(0," + textLimit + ");";
	
		var html = "<div>";
			
		if (browserInfo.isMSIE() && browserInfo.version() < 8)
		{
			html += "<table width='223px' cellspacing='0' cellpadding='0' border='0'><tr><td>";
		}
		else
		{
			html += "<table width='100%' cellspacing='0' cellpadding='0' border='0'><tr><td>";
		}
	 	 
	 	html += "<span style='margin-left:4px; font-weight:bold'>" + locale.title + "&nbsp;</span>";
	 	html += "<input id='input_OutlineName' type='text' size='25' maxlength='80' value='" + this.name + "'/><br/>";
	 	html += "<textarea onkeydown='" + limitTextLengthJavascript + "' id='textarea_OutlineInfo' ";
	 	html += browserInfo.isFirefox() ? "rows='4' " : "rows='5' ";
	 	html += "style='resize:none; width:" + (browserInfo.isMSIE() ? "223px" : "213px") + ";margin-left:4px'>" + util.replaceBr(this.info) + "</textarea><br/>";
	 	
		html += "<div><hr style='height:1px;border-width:0;color:gainsboro;background-color:gainsboro'/></div>";
	 	
		html += "<table cellspacing='3px' cellPadding='0' style='margin: 0px 0px 0px 7px'>" +
			"<tr> \
				<th style='padding-right:10px'><div><b>" + locale.lineColor + "</b></div></th> \
				<th style='padding-right:10px'><div><b>" + locale.lineOpacity + "</b></div></th> \
				<th style='padding-right:10px'><div><b>" + locale.lineSize + "</b></div></th> \
			</tr>" +



			"<tr> \
				<td> \
			   		<div onmousedown='jscolor.color(this,getElementById(\"hidden_OutlineBorderColorValue\"));' styleClass='color {valueElement:\"hidden_OutlineBorderColorValue\"}' style='display:inline-block; width:40px; height:15px; border: 1px solid dimgray; text-align:center; background-color:" + this.options.borderColor + "; cursor:pointer; ' > \
						<img src='" + territoriesImagePath + "color_grad.png'/> \
			   		<div> \
					<input id='hidden_OutlineBorderColorValue' value='" + this.options.borderColor + "' type='hidden' onchange='outlines.selectedOutline.options.borderColor = this.value;outlines.selectedOutline.redraw();'/> \
				</td>" +
				"<td> \
					<select id='select_OutlineBorderOpacity' onchange='outlines.selectedOutline.options.borderOpacity = this.options[this.selectedIndex].value;outlines.selectedOutline.redraw();'> \
						<option value='0' " + (this.options.borderOpacity == 0 ? "selected='selected'" : "") + ">0%</option> \
						<option value='.1' " + (this.options.borderOpacity == .1 ? "selected='selected'" : "") + ">10%</option> \
						<option value='.2' " + (this.options.borderOpacity == .2 ? "selected='selected'" : "") + ">20%</option> \
						<option value='.3' " + (this.options.borderOpacity == .3 ? "selected='selected'" : "") + ">30%</option> \
						<option value='.4' " + (this.options.borderOpacity == .4 ? "selected='selected'" : "") + ">40%</option> \
						<option value='.5' " + (this.options.borderOpacity == .5 ? "selected='selected'" : "") + ">50%</option> \
						<option value='.6' " + (this.options.borderOpacity == .6 ? "selected='selected'" : "") + ">60%</option> \
						<option value='.7' " + (this.options.borderOpacity == .7 ? "selected='selected'" : "") + ">70%</option> \
						<option value='.8' " + (this.options.borderOpacity == .8 ? "selected='selected'" : "") + ">80%</option> \
						<option value='.9' " + (this.options.borderOpacity == .9 ? "selected='selected'" : "") + ">90%</option> \
						<option value='1' " + (this.options.borderOpacity == 1 ? "selected='selected'" : "") + ">100%</option> \
					</select> \
				</td>" +
				"<td> \
					<select id='select_OutlineBorderWeight' onchange='outlines.selectedOutline.options.borderWeight = this.options[this.selectedIndex].value;outlines.selectedOutline.redraw();'> \
						<option value='1' " + (this.options.borderWeight == 1 ? "selected='selected'" : "") + ">1</option> \
						<option value='2' " + (this.options.borderWeight == 2 ? "selected='selected'" : "") + ">2</option> \
						<option value='3' " + (this.options.borderWeight == 3 ? "selected='selected'" : "") + ">3</option> \
						<option value='4' " + (this.options.borderWeight == 4 ? "selected='selected'" : "") + ">4</option> \
						<option value='5' " + (this.options.borderWeight == 5 ? "selected='selected'" : "") + ">5</option> \
						<option value='6' " + (this.options.borderWeight == 6 ? "selected='selected'" : "") + ">6</option> \
						<option value='7' " + (this.options.borderWeight == 7 ? "selected='selected'" : "") + ">7</option> \
						<option value='8' " + (this.options.borderWeight == 8 ? "selected='selected'" : "") + ">8</option> \
						<option value='9' " + (this.options.borderWeight == 9 ? "selected='selected'" : "") + ">9</option> \
						<option value='10' " + (this.options.borderWeight == 10 ? "selected='selected'" : "") + ">10</option> \
					</select> \
				</td> \
			</tr>" +
			
			"<tr " + (this.type == "polyline" ? "style='visibility:collapse'" : "") + "><th style='padding:7px 10px 0px 0px'><div><b>" + locale.fillColor + "</b></div></th>" +
			"<th style='padding:7px 10px 0px 0px'><div><b>" + locale.fillOpacity + "</b></div></th></tr>" +

			"<tr " + (this.type == "polyline" ? "style='visibility:collapse'" : "") + "> \
				<td> \
			   		<div onmousedown='jscolor.color(this,getElementById(\"hidden_OutlineFillColorValue\"));' styleClass='color {valueElement:\"hidden_OutlineFillColorValue\"}' style='display:inline-block; width:40px; height:15px; border: 1px solid dimgray; text-align:center; background-color:" + this.options.fillColor + "; cursor:pointer; ' > \
						<img src='" + territoriesImagePath + "color_grad.png'/> \
			   		<div> \
			   		<input id='hidden_OutlineFillColorValue' value='" + this.options.fillColor + "' type='hidden' onchange='outlines.selectedOutline.options.fillColor = this.value;outlines.selectedOutline.redraw();'/> \
				</td>" +
				"<td> \
					<select id='select_OutlineFillOpacity' onchange='outlines.selectedOutline.options.fillOpacity = this.options[this.selectedIndex].value;outlines.selectedOutline.redraw();'> \
						<option value='0' " + (this.options.fillOpacity == 0 ? "selected='selected'" : "") + ">0%</option> \
						<option value='.1' " + (this.options.fillOpacity == .1 ? "selected='selected'" : "") + ">10%</option> \
						<option value='.2' " + (this.options.fillOpacity == .2 ? "selected='selected'" : "") + ">20%</option> \
						<option value='.3' " + (this.options.fillOpacity == .3 ? "selected='selected'" : "") + ">30%</option> \
						<option value='.4' " + (this.options.fillOpacity == .4 ? "selected='selected'" : "") + ">40%</option> \
						<option value='.5' " + (this.options.fillOpacity == .5 ? "selected='selected'" : "") + ">50%</option> \
						<option value='.6' " + (this.options.fillOpacity == .6 ? "selected='selected'" : "") + ">60%</option> \
						<option value='.7' " + (this.options.fillOpacity == .7 ? "selected='selected'" : "") + ">70%</option> \
						<option value='.8' " + (this.options.fillOpacity == .8 ? "selected='selected'" : "") + ">80%</option> \
						<option value='.9' " + (this.options.fillOpacity == .9 ? "selected='selected'" : "") + ">90%</option> \
						<option value='1' " + (this.options.fillOpacity == 1 ? "selected='selected'" : "") + ">100%</option> \
					</select> \
				</td> \
			</tr></table>";
	
		html += "<div><hr style='height:1px;border-width:0;color:gainsboro;background-color:gainsboro'/></div>";
		html += "<span style='margin-left:4px'><input class='btn' onclick='outlines.selectedOutline.saveEdits();outlines.selectedOutline.switchToDisplayMode();' type='button' value='" + locale.ok + "'/></span>";
		html += "<span style='margin-left:4px'><input class='btn' onclick='outlines.selectedOutline.cancelEdits();outlines.selectedOutline.switchToDisplayMode();' type='button' value='" + locale.cancel + "'/></span>";
		html += "</td></tr></table></div>";
	
	 	return html;
	};
	
	this.getSaveTemplateHtml = function()
	{
		var html = "<div>";
			
		if (browserInfo.isMSIE() && browserInfo.version() < 8)
		{
			html += "<table width='223px' cellspacing='0' cellpadding='0' border='0'><tr><td>";
		}
		else
		{
			html += "<table width='100%' cellspacing='0' cellpadding='0' border='0'><tr><td>";
		}
		
		html += "<span><b>" + locale.saveOutlineTemplate + "</b><br/><br/> \
			<span>" + locale.enterNameForTemplate + ":</span><br/> \
			<input id='input_TemplateName' type='text' size='32' style='margin-top:2px'>";
			
		html += "<div><hr style='height:1px;border-width:0;color:gainsboro;background-color:gainsboro'/></div>";
		html += "<span style='margin-left:4px'><input class='btn' onclick='javascript:outlines.saveSelectedOutlineAsTemplate(document.getElementById(\"input_TemplateName\").value);' type='button' value='" + locale.save + "'/></span>";
		html += "<span style='margin-left:4px'><input class='btn' onclick='outlines.selectedOutline.switchToDisplayMode();' type='button' value='" + locale.cancel + "'/></span>";

		html += "</td></tr></table></div>";
		
		return html;
	};
	
	this.switchToEditInputMode = function(latLng)
	{
		this.editInputMode = true;
		
		this.originalOptions = this.options.clone();
		this.originalName = this.name;
		this.originalInfo = this.info;
		
		map.closeInfoWindow();
		map.openInfoWindowHtml(latLng, this.getEditHtml());
		
		outlines.disableAllCircleOutlineEditing();
	};

	this.switchToSaveTemplateMode = function()
	{
		var latLng = map.getInfoWindow().getPoint();
		map.openInfoWindowHtml(latLng, this.getSaveTemplateHtml());

		outlines.disableAllCircleOutlineEditing();
	}
	
	this.switchToDisplayMode = function()
	{
		this.editInputMode = false;

		var latLng = map.getInfoWindow().getPoint();
		map.closeInfoWindow();
		map.openInfoWindowHtml(latLng, this.getHtml());
		
		outlines.disableAllCircleOutlineEditing();
	};
	
	this.saveEdits = function()
	{
		this.name = document.getElementById("input_OutlineName").value;
		this.info = util.replaceCrlf(document.getElementById("textarea_OutlineInfo").value);
	};
	
	this.cancelEdits = function()
	{
		this.originalOptions.copyTo(this.options);
		this.name = this.originalName;
		this.info = this.originalInfo;
		
		this.redraw();
	};

	this.getVertices = function()
	{
		var vertices = [];
		
		for (var j = 0; j < this.polyline.getVertexCount(); j++)
		{
			vertices.push(this.polyline.getVertex(j));
		}
		
		return vertices;
	};
		
	this.redraw = function()
	{
		var vertices = this.getVertices();

		map.removeOverlay(this.polyline);
		
		if (this.type == "polygon")
		{
			this.polyline = new GPolygon(vertices, this.options.borderColor, 
				Number(this.options.borderWeight), Number(this.options.borderOpacity),
				this.options.fillColor, Number(this.options.fillOpacity));
		}
		else if (this.type == "circle")
		{
			var polygonOptions = {};
			polygonOptions.mouseOutTolerance = 10;
			
			this.polyline = new GPolygon(vertices, this.options.borderColor, 
				Number(this.options.borderWeight), Number(this.options.borderOpacity),
				this.options.fillColor, Number(this.options.fillOpacity), polygonOptions);
		}
		else
		{
			this.polyline = new GPolyline(vertices, this.options.borderColor, 
				Number(this.options.borderWeight), Number(this.options.borderOpacity));
		}

		map.addOverlay(this.polyline);

		if (this.type == "circle")
		{
			this.colorHandles();
			this.addDragListeners(this);
		}

		this.enableEditing();

		outlines.drawing.addClickListener(this);
	};

	this.getGeocodes = function()
	{
		var geocodes = "";
			
		for (var i = 0; i < this.polyline.getVertexCount(); i++)
		{
			var vertex = this.polyline.getVertex(i);
				
			if (geocodes.length > 0)
			{
				geocodes += ",";
			}
				
			geocodes += String(vertex.lat()) + ',' + String(vertex.lng());
		}

		return geocodes;		
	};
	
	this.enableEditing = function()
	{
		if (this.type == "circle")
		{
			this.enableCircleEditing();
		}
		else
		{
			this.polyline.enableEditing({onEvent: "mouseover"});
			this.polyline.disableEditing({onEvent: "mouseout"});
		}
			
		this.editingOutline = true;
	};

	this.disableEditing = function()
	{
		if (this.type == "circle")
		{
			this.disableCircleEditing();
		}
		else
		{
			this.polyline.disableEditing({onEvent: "mouseover"});
			this.polyline.disableEditing({onEvent: "mouseout"});
		}
			
		this.editingOutline = false;
	};

	this.enableDrawing = function()
	{
		var drawingOptions = {};
		drawingOptions.maxVertices = outlines.maxVertices;
		this.polyline.enableDrawing(drawingOptions);
		this.editingOutline = true;
	};
}



/////////////////////////////////////////////////////////////////////////////////////
// CircleOutline
/////////////////////////////////////////////////////////////////////////////////////
CircleOutline.prototype = new Outline();
function CircleOutline()
{
	this.setCenterAndRadius = function(center, radius)
	{
		this.center = center;
		this.radius = radius;
	};
	
	this.setIndex = function(index)
	{
		this.index = index;
	};
	
	this.getGeocodes = function()
	{
		return separator.currency + this.center.lat() + "," + this.center.lng() + "," + this.radius;
	};
	
	this.showHandles = function()
	{
		if (util.isDefined(this.resizeHandle) &&
			this.resizeHandle != null)
		{
			this.resizeHandle.style.visibility = "visible";
		}
		
		if (util.isDefined(this.centerHandle) &&
			this.centerHandle != null)
		{
			this.centerHandle.style.visibility = "visible";
		}
	};

	this.hideHandles = function()
	{
		if (util.isDefined(this.resizeHandle) &&
			this.resizeHandle != null)
		{
			this.resizeHandle.style.visibility = "hidden";
		}
		
		if (util.isDefined(this.centerHandle) &&
			this.centerHandle != null)
		{
			this.centerHandle.style.visibility = "hidden";
		}
	};
	
	this.createHandles = function()
	{
		if (!util.isDefined(this.resizeHandle) ||
			this.resizeHandle == null)
		{
			this.createResizeHandle();
		}
		
		if (!util.isDefined(this.centerHandle) ||
			this.centerHandle == null)
		{
			this.createCenterHandle();
		}

		this.colorHandles();
	};
	
	this.createResizeHandle = function()
	{
		this.resizeHandleSize = 10;
		
		this.resizeHandle = document.createElement("div");
		this.resizeHandle.style.backgroundColor = "white";
		this.resizeHandle.style.position = "absolute";
		this.resizeHandle.style.width = String(this.resizeHandleSize) + "px";
		this.resizeHandle.style.height = String(this.resizeHandleSize) + "px";
		this.resizeHandle.style.visibility = "hidden";
		this.resizeHandle.style.cursor = "pointer";
		this.resizeHandle.style.zIndex = 0;
		this.resizeHandle.setAttribute("outlineIndex", this.index);

		this.resizeHandleInnerDiv = document.createElement("div");
		this.resizeHandleInnerDiv.style.width = this.resizeHandle.style.width;
		this.resizeHandleInnerDiv.style.height = this.resizeHandle.style.height;
		this.resizeHandleInnerDiv.style.filter = "alpha(opacity=20)";
		this.resizeHandleInnerDiv.style.opacity = "0.2";				
		this.resizeHandle.appendChild(this.resizeHandleInnerDiv);
	
		this.resizeHandle.onmousedown = this.onResizeHandleMouseDown;

		document.onmousemove = this.onMouseMove;
		document.onmouseup = this.onMouseUp;

		this.setResizeHandlePosition();
		
		getMapCanvas().appendChild(this.resizeHandle);
	};
	
	this.colorHandles = function()
	{
		if (util.isDefined(this.resizeHandle) && this.resizeHandle != null)
		{
			this.resizeHandle.style.border = "1px solid " + this.options.borderColor;
		}
		
		if (util.isDefined(this.resizeHandleInnerDiv) && this.resizeHandleInnerDiv != null)
		{
			this.resizeHandleInnerDiv.style.backgroundColor = this.options.borderColor;
		}
		
		if (util.isDefined(this.centerHandle) && this.centerHandle != null)
		{
			this.centerHandle.style.border = "1px solid " + this.options.borderColor;
		}
		
		if (util.isDefined(this.centerHandleInnerDiv) && this.centerHandleInnerDiv != null)
		{
			this.centerHandleInnerDiv.style.backgroundColor = this.options.fillColor;
		}
	};

	this.onResizeHandleMouseDown = function(e)
	{
		outlines.outlineBeingEdited = outlines.getCircleOutline(this.getAttribute("outlineIndex"));
		outlines.resizingOutline = true;		
		return false;
	};

	
	this.onMouseMove = function(e)
	{
		if (!e) e = window.event;
		
		var outline = outlines.outlineBeingEdited;
		
		if (outline != null)
		{
			map.closeInfoWindow();

			var pageXOffset = browserInfo.isMSIE() ? document.documentElement.scrollLeft  : window.pageXOffset;
			var pageYOffset = browserInfo.isMSIE() ? document.documentElement.scrollTop : window.pageYOffset;
			
			if (outlines.resizingOutline)
			{
				var x = e.clientX + pageXOffset - util.getLeftPos(getMapCanvas());
				
				var y = map.fromLatLngToContainerPixel(outline.center).y;
				var dragPoint = new GPoint(x, y);
				outline.radius = outline.getDistance(outline.center, 
					map.fromContainerPixelToLatLng(dragPoint)) * 1000;

				outline.redraw();
				outline.setResizeHandlePosition();
				
				outline.showDistanceDisplay(dragPoint);
			}
			else if (outlines.movingOutline)
			{
				var x = e.clientX + pageXOffset - util.getLeftPos(getMapCanvas());
				var y = e.clientY + pageYOffset - util.getTopPos(getMapCanvas());
				outline.center = map.fromContainerPixelToLatLng(new GPoint(x, y));

				outline.redraw();
				outline.setCenterHandlePosition();
				outline.setResizeHandlePosition();
			}
		}
			
		return false;
	};
	
	this.onMouseUp = function()
	{
		
		if (outlines.resizingOutline)
		{
			outlines.outlineBeingEdited.hideDistanceDisplay();			
			outlines.resizingOutline = false;
			outlines.outlineBeingEdited = null;
		}
		else if (outlines.movingOutline)
		{
			outlines.movingOutline = false;
			outlines.outlineBeingEdited = null;
		}
	};

	this.setResizeHandlePosition = function()
	{
		if (util.isDefined(this.resizeHandle) &&
			this.resizeHandle != null)
		{
			var resizeHandlePoint = map.fromLatLngToContainerPixel(this.getCirclePoint(90));
			this.resizeHandle.style.top = String(resizeHandlePoint.y - (this.resizeHandleSize / 2)) + "px";
			this.resizeHandle.style.left = String(resizeHandlePoint.x - (this.resizeHandleSize / 2)) + "px";
		}
	};

	this.createCenterHandle = function()
	{
		this.centerHandleSize = 10;

		this.centerHandle = document.createElement("div");
		this.centerHandle.style.backgroundColor = "transparent";
		this.centerHandle.style.position = "absolute";
		this.centerHandle.style.width = String(this.centerHandleSize) + "px";
		this.centerHandle.style.height = String(this.centerHandleSize) + "px";
		this.centerHandle.style.visibility = "hidden";
		this.centerHandle.style.cursor = "pointer";
		this.centerHandle.style.zIndex = 0;
		this.centerHandle.setAttribute("outlineIndex", this.index);

		this.centerHandleInnerDiv = document.createElement("div");
		this.centerHandleInnerDiv.style.width = this.centerHandle.style.width;
		this.centerHandleInnerDiv.style.height = this.centerHandle.style.height;
		this.centerHandleInnerDiv.style.filter = "alpha(opacity=20)";
		this.centerHandleInnerDiv.style.opacity = "0.2";				
		this.centerHandle.appendChild(this.centerHandleInnerDiv);

		this.centerHandle.onmousedown = this.onCenterHandleMouseDown;

		this.setCenterHandlePosition();
		
		getMapCanvas().appendChild(this.centerHandle);
	};
	
	this.onCenterHandleMouseDown = function(e)
	{
		outlines.outlineBeingEdited = outlines.getCircleOutline(this.getAttribute("outlineIndex"));
		outlines.movingOutline = true;		
		return false;
	};
	
	this.setCenterHandlePosition = function()
	{
		if (util.isDefined(this.centerHandle) &&
			this.centerHandle != null)
		{
			var centerHandlePoint = map.fromLatLngToContainerPixel(this.center);
			this.centerHandle.style.top = String(centerHandlePoint.y - (this.centerHandleSize / 2)) + "px";
			this.centerHandle.style.left = String(centerHandlePoint.x - (this.centerHandleSize / 2)) + "px";
		}
	};
	
	this.createDistanceDisplay = function()
	{
		if (!util.isDefined(this.distanceDisplay) ||
			this.distanceDisplay == null)
		{
			this.distanceDisplay = document.createElement("div");
		}
		
		this.distanceDisplay.style.border = "1px solid red";
		this.distanceDisplay.style.backgroundColor = "yellow";
		this.distanceDisplay.style.padding = "0px 3px 0px 3px";
		this.distanceDisplay.style.fontSize = "90%";
		this.distanceDisplay.style.position = "absolute";
		
		getMapCanvas().appendChild(this.distanceDisplay);
	};
	
	this.showDistanceDisplay = function(dragPoint)
	{
		if (!util.isDefined(this.distanceDisplay) ||
			this.distanceDisplay == null)
		{
			this.createDistanceDisplay();
		}

		this.distanceDisplay.style.left = (dragPoint.x + 10) + "px";
		this.distanceDisplay.style.top = (dragPoint.y + 10) + "px";

		this.distanceDisplay.innerHTML = String(this.getDisplayText());
	};
	
	this.getDisplayText = function()
	{
		var displayText = "<b>" + locale.radius + ":&nbsp;</b>";
		if (this.radius < 1000)
		{
			displayText += util.formatNumber(this.radius, 2) + " m (";
		}
		else
		{
	      	displayText += util.formatNumber((this.radius / 1000), 2) + " km (";
		}

	    var britishRadius = this.radius * 3.2808399;
	    if (britishRadius < 5280)
	    {
	    	displayText += util.formatNumber(britishRadius, 2) + " ft)";
	    }
	    else
	    {
	     	displayText += util.formatNumber((britishRadius / 5280), 2) + " mi)";
	    }
	    
	    return displayText;
	};
	
	this.hideDistanceDisplay = function()
	{
		if (util.isDefined(this.distanceDisplay))
		{
			getMapCanvas().removeChild(this.distanceDisplay);
			this.distanceDisplay = null;
		}	
	};
	
	this.enableCircleEditing = function()
	{
		this.createHandles();
		this.addDragListeners(this);
	};
	
	this.disableCircleEditing = function()
	{
		this.hideHandles();

		if (util.isDefined(this.resizeHandle) &&
			this.resizeHandle != null)
		{
			getMapCanvas().removeChild(this.resizeHandle);
			this.resizeHandle = null;
		}
		
		if (util.isDefined(this.centerHandle) &&
			this.centerHandle != null)
		{
			getMapCanvas().removeChild(this.centerHandle);
			this.centerHandle = null;
		}
		
		this.removeDragListeners(this);		
	};

	this.addDragListeners = function(outline)
	{
		outline.removeDragListeners(outline);
		
		outline.mouseOverDragListener = GEvent.addListener(outline.polyline, "mouseover",
			function()
			{
				outline.showHandles();
			}
		);
			
		outline.mouseOutDragListener = GEvent.addListener(outline.polyline, "mouseout",
			function()
			{
				outline.hideHandles();
			}
		);

		outline.mapDragListener = GEvent.addListener(map, "drag", 
			function() 
			{
				outline.setResizeHandlePosition();
				outline.setCenterHandlePosition();
			}
		);
		
		outline.mapMoveListener = GEvent.addListener(map, "move", 
			function() 
			{
				outline.setResizeHandlePosition();
				outline.setCenterHandlePosition();
			}
		);
	};

	
	this.removeDragListeners = function(outline)
	{
		if (util.isDefined(outline.mouseOverDragListener) &&
			outline.mouseOverDragListener != null)
		{
			GEvent.removeListener(outline.mouseOverDragListener);
		}
		
		if (util.isDefined(outline.mouseOutDragListener) &&
			outline.mouseOutDragListener != null)
		{
			GEvent.removeListener(outline.mouseOutDragListener);
		}
		
		if (util.isDefined(outline.mapDragListener) &&
			outline.mapDragListener != null)
		{
			GEvent.removeListener(outline.mapDragListener);
		}

		if (util.isDefined(outline.mapMoveListener) &&
			outline.mapMoveListener != null)
		{
			GEvent.removeListener(outline.mapMoveListener);
		}
	};

	this.getVertices = function()
	{
		var vertices = [];

		for (var i = 0; i < 72; i++) 
		{
			vertices.push(this.getCirclePoint(i * 360 / 72));
		}
		
    	vertices.push(new GLatLng(vertices[0].lat(), vertices[0].lng()));
		
		return vertices;
	};

	this.getCirclePoint = function(angle) 
	{
  		var earthRadius = 6371;
  		var angularDistance = this.radius / 1000 / earthRadius;
 		angle = util.degreesToRadians(angle); 
 		var centerX = util.degreesToRadians(this.center.lng());
 		var centerY = util.degreesToRadians(this.center.lat());

 		var pointY = Math.asin(Math.sin(centerY) * Math.cos(angularDistance) + 
 			Math.cos(centerY) * Math.sin(angularDistance) * Math.cos(angle));
 		var pointX = centerX + Math.atan2(Math.sin(angle) * Math.sin(angularDistance) * 
 			Math.cos(centerY), Math.cos(angularDistance) - Math.sin(centerY) * Math.sin(pointY));

 		pointY = util.radiansToDegrees(pointY);
 		pointX = util.radiansToDegrees(pointX);

 		return new GLatLng(pointY, pointX);
	};

	this.getDistance = function(point1, point2) 
	{
  		var earthRadius = 6371;
  		var lon1 = util.degreesToRadians(point1.lng());
  		var lat1 = util.degreesToRadians(point1.lat());
  		var lon2 = util.degreesToRadians(point2.lng());
  		var lat2 = util.degreesToRadians(point2.lat());

  		var deltaLat = lat1 - lat2
  		var deltaLon = lon1 - lon2

  		var step1 = Math.pow(Math.sin(deltaLat / 2), 2) + Math.cos(lat2) * Math.cos(lat1) * 
  			Math.pow(Math.sin(deltaLon / 2), 2);
  		var step2 = 2 * Math.atan2(Math.sqrt(step1), Math.sqrt(1 - step1));
  		return step2 * earthRadius;
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// Outlines
/////////////////////////////////////////////////////////////////////////////////////
function Outlines()
{
	this.ZIP_CODE_OUTLINE_URL = "http://maps.huge.info/zipv0.pl?ZIP=";
	
	this.outlines = [];
	this.readOnlyOutlines = []; // needed for exports
	
	this.circleOutlineIndex = 0;
	
	this.DEFAULT_OUTLINE_OPTIONS_DATA = "#ff0000" + separator.para + "2" + separator.para + "0.7" + separator.para + "#ff0000" + separator.para + "0.2";
	this.DEFAULT_OUTLINE_OPTIONS = new OutlineOptions(this.DEFAULT_OUTLINE_OPTIONS_DATA);
	this.DEFAULT_OUTLINE_NAME = locale.untitled;
	this.DEFAULT_OUTLINE_INFO = "";

	this.publicOutlinesSheetKey = "thzPhzM3CbEnraGx1fOouhg";
	
	this.loader = new OutlineLoader();
	this.drawing = new OutlineDrawing();
	
	this.maxVertices = 100;
	this.MAX_OUTLINES = 50;
	
	this.outlinesEditorOpen = false;
	
	var selectedOutline;
	
	this.initialize = function()
	{
		this.enableEditing();
		
		GEvent.addListener(map, "infowindowclose",
			function()
			{
				if (outlines.outlinesEditorOpen)
				{
					outlines.enableAllCircleOutlineEditing();
				}
			}
		);
	};

	this.enableAllCircleOutlineEditing = function()
	{
		for (var i = 0; i < this.outlines.length; i++)
		{
			if (this.outlines[i].type == "circle")
			{
				this.outlines[i].enableCircleEditing();
			}
		}
	};

	this.disableAllCircleOutlineEditing = function()
	{
		for (var i = 0; i < this.outlines.length; i++)
		{
			if (this.outlines[i].type == "circle")
			{
				this.outlines[i].disableCircleEditing();
			}
		}
	};

	this.getCircleOutline = function(index)
	{
		for (var i = 0; i < this.outlines.length; i++)
		{
			if (this.outlines[i].type == "circle" &&
				this.outlines[i].index == index)
			{
				return this.outlines[i];
			}
		}
		
		return null;
	};

	this.appendOutline = function(outline)
	{
		if (outline.readOnly)
		{
			this.readOnlyOutlines.push(outline);
		}
		else
		{
			this.outlines.push(outline);
		}
		
		if (outline.type == "circle")
		{
			outline.setIndex(String(this.circleOutlineIndex++));
		}
	};

	this.addOutline = function(geocodes, options, name, info, enableDrawing, enableEditing, readOnly)
	{
		var polyType = (geocodes[0].lat() == geocodes[geocodes.length - 1].lat() &&
			geocodes[0].lng() == geocodes[geocodes.length - 1].lng()) ? "polygon" : "polyline";
	
		var poly;
		
		if (polyType == "polygon")
		{
			var poly = new GPolygon(geocodes, options.borderColor, 
				Number(options.borderWeight), Number(options.borderOpacity),
				options.fillColor, Number(options.fillOpacity));
		}
		else
		{
			var poly = new GPolyline(geocodes, options.borderColor, 
				Number(options.borderWeight), Number(options.borderOpacity));
		}
		
		var outline = new Outline();
		outline.init(poly, polyType, options, name, info, readOnly);
		
		this.drawing.startDrawing(outline, enableDrawing, enableEditing,
			function()
			{
				// this method will be called on outlines
			}
		);
		
		GEvent.trigger(outline.polyline, "endline");
	};
	
	this.onOpenOutlinesEditor = function()
	{
		map.closeInfoWindow();
		
		this.outlinesEditorOpen = true;
		this.fetchPublicOutlinesList();
	};
		
	this.onCloseOutlines = function()
	{
		this.outlinesEditorOpen = false;
		
		map.closeInfoWindow();
		
		if (typeof jscolor != "undefined" &&
			typeof jscolor.hidePicker == "function")
		{		
			jscolor.hidePicker();
		}
		
		this.drawing.stopDrawing();
		this.saveAllOutlineData();
		this.disableEditing()
	};		

	this.onQuickSave = function()
	{
		this.saveAllOutlineData();
	};
		
	this.verifyOutlineCount = function()
	{
		if (this.outlines.length >= this.MAX_OUTLINES)
		{
			alert(locale.outlineLimitReached.replace("{0}", String(this.MAX_OUTLINES)));
			return false;
		}
		
		return true;
	};		
		
	this.fetchPublicOutlinesList = function()
	{
		removeOldScriptNodes();

  		var script = document.createElement("script");
    	script.setAttribute("src", "http://spreadsheets.google.com/feeds/cells/" +
    		this.publicOutlinesSheetKey + "/1/public/values?alt=json-in-script&callback=listPublicOutlinesCallback");
		script.setAttribute("id", "outlinesScript");
  		script.setAttribute("type", "text/javascript");
		document.documentElement.firstChild.appendChild(script);
	};
	
	this.listPublicOutlines = function(publicOutlinesJson)
	{
		for (var i = 0; i < publicOutlinesJson.feed.entry.length; i += 2) 
		{
			var name = publicOutlinesJson.feed.entry[i].content.$t;
			var value = publicOutlinesJson.feed.entry[i + 1].content.$t;
			
			var publicOutlinesListSelect = document.getElementById("select_PublicOutlines");
			util.addSelectListOption(publicOutlinesListSelect, value, name);
		}
		
		util.hideLoadingImage();
	};

	this.publicOutlineTypeSelected = function()
	{
		var selectedType = $("#select_PublicOutlines option:selected").val();
		
		if (selectedType === "NONE")
		{
			$("#span_SelectPublicOutline").hide();
			$("#span_ZipCodeEntry").hide();
			return;
		}
		else if (selectedType === "zipCodes")
		{
			$("#span_ZipCodeEntry").show();
			$("#span_SelectPublicOutline").hide();
		}
		else
		{
			$("#span_SelectPublicOutline").show();
			$("#span_ZipCodeEntry").hide()

			util.showLoadingImage();
			this.fetchPublicOutlineItems();
		}
	};

	this.fetchPublicOutlineItems = function()
	{
		var publicOutlinesListSelect = $("#select_PublicOutlines").get(0);

		removeOldScriptNodes();

		var outlineItemsSheetKey = publicOutlinesListSelect.options[publicOutlinesListSelect.selectedIndex].value;

  		var script = document.createElement("script");
    	script.setAttribute("src", "http://spreadsheets.google.com/feeds/cells/" +
    		outlineItemsSheetKey + "/1/public/values?alt=json-in-script&callback=listPublicOutlineItemsCallback");
		script.setAttribute("id", "outlinesScript");
  		script.setAttribute("type", "text/javascript");
		document.documentElement.firstChild.appendChild(script);
	};

	this.listPublicOutlineItems = function(publicOutlinesJson)
	{
		var publicOutlinesItemsSelect = document.getElementById("select_PublicOutlineItems");
	
		for (var i = 0; i < publicOutlinesJson.feed.entry.length; i += 2) 
		{
			var name = publicOutlinesJson.feed.entry[i].content.$t;
			var value = publicOutlinesJson.feed.entry[i + 1].content.$t;
			
			util.addSelectListOption(publicOutlinesItemsSelect, value, name);
		}
		
		util.hideLoadingImage();		
	};
	
	this.loadZipCode = function()
	{
		var zipCodeInput = $("#input_ZipCode");
		var zip = $.trim(zipCodeInput.val());
		
		if (zip.length != 5)
		{
			return;
		}
		
		var url = this.ZIP_CODE_OUTLINE_URL + zip;

		var _this = this;
		
		sforce.connection.remoteFunction(
		{
			url : url, 
			onSuccess : function(response) { _this.loadZipCodeOutline(response); },
			onFailure : function(response) { alert("An error occurred: " + response); },
			mimeType : "text/xml",
			async : true,
			cache : true			
		});
		
		zipCodeInput.val("");
	};

	this.loadZipCodeOutline = function(xmlDocument)
	{
		var geocodes = [];
		
		var documentNode = $(xmlDocument);
		documentNode.find("polyline1").each(function(index)
		{
			geocodes.push(new GLatLng(Number($(this).attr("lat")), Number($(this).attr("lng"))));
		}); 
		
		if (geocodes.length === this.maxVertices)
		{
			alert("Only the first " + this.maxVertices + " vertices will be plotted");
			geocodes.length = this.maxVertices;
		}
		
		var infoNode = documentNode.find("info").first();
		var outlineName = infoNode.attr("zipcode");
		var outlineInfo = infoNode.attr("zipname") + ", " + infoNode.attr("uspsst");

		this.addOutline(geocodes, new OutlineOptions(outlines.DEFAULT_OUTLINE_OPTIONS_DATA), 
			outlineName, outlineInfo, false, true, false);
		
		var centerPointNode = documentNode.find("marker1").first();
		
		centerLatitude = Number(centerPointNode.attr("lat"));
		centerLongitude = Number(centerPointNode.attr("lng"));
		initialZoom = 13;
		territories.resetMap();
 
	};

	this.loadPublicOutline = function()
	{
		if(!this.verifyOutlineCount())
		{
			return;
		}
		
		util.showLoadingImage();
		
		var publicOutlinesListSelect = document.getElementById("select_PublicOutlines");
		var publicOutlinesItemsSelect = document.getElementById("select_PublicOutlineItems");

		var outlineItemsSheetKey = publicOutlinesListSelect.options[publicOutlinesListSelect.selectedIndex].value;
		var columnIndex = publicOutlinesItemsSelect.selectedIndex;
		
		var publicOutlineData = outlineItemsSheetKey + separator.para + String(columnIndex);
		
		outlines.loader.loadPublicOutline(publicOutlineData);
		
		var publicOutlinesItemsSelect = document.getElementById("select_PublicOutlineItems");
		publicOutlinesItemsSelect.selectedIndex = 0;
		
		util.hideLoadingImage();
	};
	
	this.removeSelectedOutline = function()
	{
		for (var i = 0; i < this.outlines.length; i++)
		{
			if (this.outlines[i] === this.selectedOutline)
			{
				map.removeOverlay(this.outlines.splice(i, 1)[0].polyline);
				return;
			}
		}
	};
	
	this.removeOutlines = function()
	{
		var outlineCount = this.outlines.length;
		
		for (var i = 0; i < outlineCount; i++)
		{
			map.removeOverlay(this.outlines.pop().polyline);
		}
	};
	
	this.enableEditing = function()
	{
		for (var i = 0; i < this.outlines.length; i++)
		{
			this.outlines[i].enableEditing();
		}
	};
	
	this.disableEditing = function()
	{
		for (var i = 0; i < this.outlines.length; i++)
		{
			this.outlines[i].disableEditing();
		}
	};

	this.clearAllOutlines = function()
	{
		this.removeOutlines();
		this.outlines = [];
	};

	this.loadCircleOutlineFromData = function(name, info, options, outlineData, enableEditing, readOnly)
	{
		var outlineDataItems = outlineData.split(",");
		var center = new GLatLng(Number(outlineDataItems[0]), Number(outlineDataItems[1]));
		var radius = Number(outlineDataItems[2]);
		
		var outline = this.drawing.drawCircleOutline(name, info, options, center, radius, readOnly);
		
   		outlines.appendOutline(outline);
   		
   		if (enableEditing)
   		{
   			 outline.enableEditing();
   		}
   		
   		return true;
	};

	this.loadOutlineFromData = function(outlineDataInputId, enableEditing, readOnly)
	{
		var outlineData = document.getElementById(outlineDataInputId).value;
		
		if (outlineData == null || outlineData.length == 0)
		{
			return false;
		}

		var outlineDataItems = outlineData.split(separator.section);
		var outlineName = outlineDataItems[0];
		var outlineInfo = outlineDataItems[1];
		var outlineOptions = new OutlineOptions(outlineDataItems[2]);
		var geocodeData = outlineDataItems[3]; 

		if (geocodeData.substr(0, 1) == separator.currency)
		{
			return this.loadCircleOutlineFromData(outlineName, outlineInfo,
				outlineOptions, geocodeData.slice(1), enableEditing, readOnly);
		}
		
		var outlineGeocodes = geocodeData.split(","); 
		var geocodes = [];
			
		for (var i = 0; i < outlineGeocodes.length; i += 2)
		{
			geocodes.push(new GLatLng(Number(outlineGeocodes[i]), Number(outlineGeocodes[i + 1])));
		}

		this.addOutline(geocodes, outlineOptions, outlineName, outlineInfo, false, enableEditing, readOnly);
		
		return true;
	};

	this.loadTemplate = function()
	{
		util.hideLoadingImage();
		this.loadOutlineFromData("page_Territories:form_Territories:hidden_OutlineTemplate", true);
		document.getElementById("page_Territories:form_Territories:hidden_OutlineTemplate").value = "";
	};

	this.loadViewOutlines = function(readOnly)
	{
		for (var i = 0; i < this.MAX_OUTLINES; i++)
		{
			if (!this.loadOutlineFromData("page_Territories:form_Territories:hidden_Outline" + String(i + 1), false, readOnly))
			{
				break;
			}
		}

		this.clearAllOutlineData();
	};

	this.saveAllOutlineData = function()
	{
		this.clearAllOutlineData();
		
		for (var i = 0; i < this.outlines.length; i++)
		{
			document.getElementById("page_Territories:form_Territories:hidden_Outline" + String(i + 1)).value = 
				this.outlines[i].options.toOptionString() + separator.section + 
				this.outlines[i].name + separator.section + this.outlines[i].info + separator.section + 
				this.outlines[i].getGeocodes();
		}
	};
	
	this.saveSelectedOutlineAsTemplate = function(templateName)
	{
		if (util.trim(templateName).length == 0)
		{
			alert(locale.enterNameForTemplate);
			return;
		}
		
		var outlineTemplate = this.selectedOutline.options.toOptionString() + separator.section + 
			templateName + separator.section + separator.section + this.selectedOutline.getGeocodes();
			
		map.closeInfoWindow();			
		util.showLoadingImage();
		saveOutlineTemplate(outlineTemplate);
	};
	
	this.afterSaveTemplate = function()
	{
		util.hideLoadingImage();
		this.selectedOutline.switchToDisplayMode();
	};
	
	this.clearAllOutlineData = function()
	{
		for (var i = 0; i < this.MAX_OUTLINES; i++)
		{
			document.getElementById("page_Territories:form_Territories:hidden_Outline" +
				String(i + 1)).value = "";
		}
	};
	
	this.cleanUp = function()
	{
		this.drawing.stopDrawing();
	};
}
/////////////////////////////////////////////////////////////////////////////////////
// OutlineOptions
/////////////////////////////////////////////////////////////////////////////////////
function OutlineOptions(outlineOptionsData)
{
	var outlineOptionsDataItems = outlineOptionsData.split(separator.para);

	this.borderColor = outlineOptionsDataItems[0];
	this.borderWeight = outlineOptionsDataItems[1];
	this.borderOpacity = outlineOptionsDataItems[2];
	this.fillColor = outlineOptionsDataItems[3];
	this.fillOpacity = outlineOptionsDataItems[4];
	
	this.toOptionString = function()
	{
		return this.borderColor + separator.para +
			this.borderWeight + separator.para +
			this.borderOpacity + separator.para +
			this.fillColor + separator.para +
			this.fillOpacity;
	};
	
	this.clone = function()
	{
		return new OutlineOptions(this.toOptionString());
	};
	
	this.copyTo = function(outlineOptions)
	{
		outlineOptions.borderColor = this.borderColor;
		outlineOptions.borderWidth = this.borderWidth;
		outlineOptions.borderOpacity = this.borderOpacity;
		outlineOptions.fillColor = this.fillColor;
		outlineOptions.fillOpacity = this.fillOpacity;
	};
}
/////////////////////////////////////////////////////////////////////////////////////
// OutlineDrawing
/////////////////////////////////////////////////////////////////////////////////////
function OutlineDrawing()
{
	var outlineBeingDrawn;
	this.circleClickEventListener = null;
	this.drawingMode = false;
	
	this.startLine = function()
	{
		if (!outlines.verifyOutlineCount())
		{
			return;
		}
	
		this.selectButton("line");

		var line = new GPolyline([], outlines.DEFAULT_OUTLINE_OPTIONS.borderColor, 
			Number(outlines.DEFAULT_OUTLINE_OPTIONS.borderWeight), 
			Number(outlines.DEFAULT_OUTLINE_OPTIONS.borderOpacity));

		var outline = new Outline();
		outline.init(line, "polyline", new OutlineOptions(outlines.DEFAULT_OUTLINE_OPTIONS_DATA),
			outlines.DEFAULT_OUTLINE_NAME, outlines.DEFAULT_OUTLINE_INFO, false);
			
		this.startDrawing(outline, true, true,
			function()
			{
				// this method will be called on outlines
			}
		);
	};
	
	this.startShape = function()
	{
		if (!outlines.verifyOutlineCount())
		{
			return;
		}
		
		this.selectButton("shape");
		
		var polygon = new GPolygon([], outlines.DEFAULT_OUTLINE_OPTIONS.borderColor, 
			Number(outlines.DEFAULT_OUTLINE_OPTIONS.borderWeight), Number(outlines.DEFAULT_OUTLINE_OPTIONS.borderOpacity), 
			outlines.DEFAULT_OUTLINE_OPTIONS.fillColor, Number(outlines.DEFAULT_OUTLINE_OPTIONS.fillOpacity));
			
		var outline = new Outline();
		outline.init(polygon, "polygon", new OutlineOptions(outlines.DEFAULT_OUTLINE_OPTIONS_DATA),
			outlines.DEFAULT_OUTLINE_NAME, outlines.DEFAULT_OUTLINE_INFO, false);
			
		this.startDrawing(outline, true, true,
			function()
			{
				// this method will be called on outlines
			}
		);
		
		this.setDrawingMode();
	};
	
	this.startCircle = function()
	{
		if (!outlines.verifyOutlineCount())
		{
			return;
		}
		
		this.selectButton("circle");
		
		if (!util.isDefined(this.mapClickCircleListener))
		{
			this.circleClickEventListener = GEvent.addListener(map, "click", 
				function(overlay, point, overlayPoint) 
				{
					var clickPoint = overlay == null ? point : overlayPoint;
					var radius = 12.5 * Math.pow(2, (19 - map.getZoom()));
	    			var outline = outlines.drawing.drawCircleOutline(outlines.DEFAULT_OUTLINE_NAME,
	    				outlines.DEFAULT_OUTLINE_INFO, new OutlineOptions(outlines.DEFAULT_OUTLINE_OPTIONS_DATA), 
	    				clickPoint, radius, false);
	    			outline.enableEditing();
	    			
		    		outlines.appendOutline(outline);
		    		
					outlines.selectedOutline = outline;
					outline.switchToEditInputMode(point);
					outlines.drawing.clearDrawingMode();
	    		}
	    	);
		}
    		
    	outlines.drawing.setDrawingMode();
	};
	
	this.drawCircleOutline = function(name, info, options, center, radius, readOnly)
	{
		var outline = new CircleOutline();
		outline.setCenterAndRadius(center, radius);

		var vertices = outline.getVertices();

		var polygonOptions = {};
		polygonOptions.mouseOutTolerance = 10;
		
		var polygon = new GPolygon(vertices, options.borderColor, 
			Number(options.borderWeight), Number(options.borderOpacity),
			options.fillColor, Number(options.fillOpacity), polygonOptions);
		
		outline.init(polygon, "circle", options, name, info, readOnly);
			
		map.addOverlay(outline.polyline);

		if (this.circleClickEventListener != null)
		{
			GEvent.removeListener(this.circleClickEventListener);
			this.circleClickEventListener = null;
		}

		this.addClickListener(outline);
		outline.addDragListeners(outline);		

		return outline;
	};
	
	this.selectButton = function(buttonName)
	{
		var handButton = document.getElementById("button_Hand");
		if (handButton != null)
		{ 
			handButton.style.backgroundImage = "url('" + territoriesImagePath + 
				(buttonName == "hand" ? "Bsd.png" : "Bsu.png") + "')";
		}
		
		var lineButton = document.getElementById("button_DrawLine");
		if (lineButton != null)
		{ 
			lineButton.style.backgroundImage = "url('" + territoriesImagePath + 
				(buttonName == "line" ? "Bld.png" : "Blu.png") + "')";
		}
		
		var shapeButton = document.getElementById("button_DrawShape");
		if (shapeButton != null)
		{ 
			shapeButton.style.backgroundImage = "url('" + territoriesImagePath + 
			(buttonName == "shape" ? "Bpd.png" : "Bpu.png") + "')";
		}

		var circleButton = document.getElementById("button_DrawCircle");
		if (circleButton != null)
		{ 
			circleButton.style.backgroundImage = "url('" + territoriesImagePath + 
			(buttonName == "circle" ? "Bcd.png" : "Bcu.png") + "')";
		}
	};

	this.addClickListener = function(outline)
	{
		GEvent.addListener(outline.polyline, "click",
			function(latLng, index)
			{
				if (typeof index == "number")
				{
					outline.polyline.deleteVertex(index);
				}
				else
				{
					if (outlines.drawing.drawingMode ||
						addMapMarker.draggableCustomLocationListener != null)
					{
						GEvent.trigger(map, "click", null, latLng);
					}
					else
					{
						outlines.selectedOutline = outline;
						map.openInfoWindowHtml(latLng, outline.getHtml());
						
						outlines.disableAllCircleOutlineEditing();
					}
				}
			}
		);
	};

	this.startDrawing = function(outline, enableDrawing, enableEditing, updateHandler)
	{
		this.outlineBeingDrawn = outline;
		map.addOverlay(outline.polyline);

		if (enableDrawing)
		{
			outline.enableDrawing();
		}
		
		if (enableEditing)
		{
			outline.enableEditing();
		}
		
		GEvent.addListener(outline.polyline, "endline", 
			function()
			{
				if (outline.polyline.getVertexCount() > 0)
				{
					outlines.appendOutline(outline);
					outlines.drawing.outlineBeingDrawn = null;
					
					if (outlines.outlinesEditorOpen)
					{
						outlines.selectedOutline = outline;
						outline.switchToEditInputMode(outline.polyline.getVertex(outline.polyline.getVertexCount() - 1));
					}
				}
				
				outlines.drawing.clearDrawingMode();
				
				GEvent.bind(outline.polyline, "lineupdated", outlines, updateHandler);
				
				outlines.drawing.addClickListener(outline);
			}
		);
	};
	
	this.stopDrawing = function()
	{
		if (this.outlineBeingDrawn != null)
		{
			this.outlineBeingDrawn.polyline.disableEditing();
			map.removeOverlay(this.outlineBeingDrawn.polyline);
		}
		
		this.clearDrawingMode();
	};
	
	this.setDrawingMode = function()
	{
		this.drawingMode = true;
	};
	
	this.clearDrawingMode = function()
	{
		this.selectButton("hand");
		this.drawingMode = false;
	};
}


/////////////////////////////////////////////////////////////////////////////////////
// OutlineLoader
/////////////////////////////////////////////////////////////////////////////////////
function OutlineLoader()
{
	this.loadPublicOutline = function(publicOutlineData)
	{
		var outlineDataItems = publicOutlineData.split(separator.para);
		var outlineItemsSheetKey = outlineDataItems[0];
		var columnIndex = outlineDataItems[1];
		
		removeOldScriptNodes();
	
  		var script = document.createElement("script");
    	script.setAttribute("src", "http://spreadsheets.google.com/feeds/cells/" +
    		outlineItemsSheetKey + "/2/public/values?min-col=" + columnIndex +
    		"&max-col=" + columnIndex + "&alt=json-in-script&callback=loadOutlineCallback");
		script.setAttribute("id", "outlinesScript");
  		script.setAttribute("type", "text/javascript");
		document.documentElement.firstChild.appendChild(script);
	};
	
	this.formatOutlineGeocodes = function(publicOutlinesJson)
	{
		var geocodes = [];
		
		for (var i = 1; i < publicOutlinesJson.feed.entry.length; i += 2) 
		{
			var geocode = new GLatLng(Number(publicOutlinesJson.feed.entry[i].content.$t),
				Number(publicOutlinesJson.feed.entry[i + 1].content.$t));
				
			geocodes.push(geocode);
		}		

		outlines.addOutline(geocodes, new OutlineOptions(outlines.DEFAULT_OUTLINE_OPTIONS_DATA), 
			outlines.DEFAULT_OUTLINE_NAME, outlines.DEFAULT_OUTLINE_INFO, false, true, false);
	};
}

/////////////////////////////////////////////////////////////////////////////////////
// Globals
/////////////////////////////////////////////////////////////////////////////////////

function removeOldScriptNodes()
{
	var script = document.getElementById("outlinesScript");
	
  	if (script != null)
  	{
    	script.parentNode.removeChild(script);
  	}
};	

function listPublicOutlinesCallback(publicOutlinesJson)
{
	outlines.listPublicOutlines(publicOutlinesJson);
}

function listPublicOutlineItemsCallback(publicOutlinesJson)
{
	outlines.listPublicOutlineItems(publicOutlinesJson);
}

function loadOutlineCallback(publicOutlinesJson)
{
	outlines.loader.formatOutlineGeocodes(publicOutlinesJson);
}
