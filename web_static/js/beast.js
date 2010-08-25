var checked = false;

function onOpsTabSelected(event, ui) {
	if (ui.tab.hash == "#search") {
		onLoadSearch();
	} else if (ui.tab.hash == '#sets_view') {
		onLoadHeatmapSetsView();
	} else if (ui.tab.hash == '#members_view') {
		onLoadHeatmapMembersView();
	} else if (ui.tab.hash == '#import') {
		onLoadImport();
	} else if (ui.tab.hash == '#browse') {
		onLoadBrowse();
	}
	// import tab is loaded initially
}

function onViewTabSelected(event, ui) {
	if (ui.tab.hash == "#mysets_tree") {
		onLoadMySetsTree(event, ui);
	} else if (ui.tab.hash == '#mysets_flat') {
		onLoadMySetsFlat(event, ui);
	} else if (ui.tab.hash == '#mycollections') {
		onLoadMyCollections(event, ui);
	}
}

function clearSession() {
	$.get('/cgi-bin/BEAST/index.pl', 
		{action:"clear"}
	);
}

function onLoadImport() {
	$('#import').empty().html('<img src="images/ajax-loader.gif" />');
	$('#import').load('/cgi-bin/BEAST/index.pl', 
		{action:"import"}
	);
}

function onLoadBrowse() {
	$('#browse').empty().html('<img src="images/ajax-loader.gif" />');
	$('#browse').load('/cgi-bin/BEAST/index.pl', 
		{action:"browse"}
	);
}

function onLoadSearch() {
	$('#search').empty().html('<img src="images/ajax-loader.gif" />');
	$('#search').load('/cgi-bin/BEAST/index.pl', 
		{action:"search"}
	);
}

function onLoadHeatmapSetsView() {

	document.imageLock = false;

	$('#sets_view').empty().html('<img src="images/ajax-loader.gif" />');
	$('#sets_view').load('/cgi-bin/BEAST/index.pl', 
		{action:"heatmap",
		 type:"sets"}
	);
}

function onLoadHeatmapMembersView() {

	document.imageLock = false;

	$('#members_view').empty().html('<img src="images/ajax-loader.gif" />');
	$('#members_view').load('/cgi-bin/BEAST/index.pl', 
		{action:"heatmap",
		 type:"members"}
	);
}


function onLoadView() {

	document.imageLock = false;

	$.getJSON('/cgi-bin/BEAST/index.pl',  { action:"mysets", format:"json" }, 
		function(data){
			//alert('JSON Data view'+data._name);
			var viewDiv = document.getElementById('view');
			viewDiv.innerHTML = "";
	
			// create set objects
			var sets = new Array();
			for (var index in data._elements) {
				sets.push(new Set(data._elements[index]));
			}
		
			// test stuff	
			var html = "<b>";
			for (var i=0; i < sets.length; i++) {
				var set = sets[i];
				var elements = set.getElements();
				html =  html+"<li>"+set.display();
				//for (i=0; i < elements.length; i++) {
				//	html = html+elements[i];
				//}
				html = html+"</li>";
			}
			html = html+"</b>";

			viewDiv.innerHTML = html;
		}
	);
}

function onLoadMySetsTree(event, ui) {
	$('#mysets_tree').empty().html('<img src="images/ajax-loader.gif" />');
	$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		{action:'mysets',
		 type:'tree'}
	);
}

function onLoadMySetsFlat(event, ui) {

	document.imageLock = false;

	$('#mysets_flat').empty().html('<img src="images/ajax-loader.gif" />');
	$('#mysets_flat').load('/cgi-bin/BEAST/index.pl', 
		{action:'mysets',
		 type:'flat'}
	);
}

function onLoadMyCollections(event, ui) {
	$('#mycollections').empty().html('<img src="images/ajax-loader.gif" />');
	$('#mycollections').load('/cgi-bin/BEAST/index.pl', 
		{action:'mycollections'}
	);
}

function selectStyle(selected, deselected)
{
    var el = document.getElementById(selected);
    if(el != null)
        el.style.fontWeight = "bold";
    el = document.getElementById(deselected);
    if(el != null)
        el.style.fontWeight = "normal";
}

function chooseFileImport(form) {
	try {
		form.importType[1].checked = true;
		var file = document.getElementById("file_upload_button");
		var text = document.getElementById("setsImportFromText");
		
		file.disabled = false;
		text.disabled = true;

		for (i=0; i < form.elements.length; i++) {
			if (form.elements[i].type == "select-one") {
				form.elements[i].disabled = true;
			}	
		}

		file.select();
		file.focus();
		// grey-out the unselected item
		selectStyle("fileStyle", "textStyle");
	} catch(e){ 
		alert(e.value);
	}
}

function chooseTextImport(form) {
	try {
		form.importType[0].checked = true;
		var file = document.getElementById("file_upload_button");
		var text = document.getElementById("setsImportFromText");

		file.disabled = true;
		text.disabled = false;

		for (i=0; i < form.elements.length; i++) {
			if (form.elements[i].type == "select-one") {
				form.elements[i].disabled = false;
			}	
		}

		text.select();
		text.focus();
		// grey-out the unselected item
		selectStyle("textStyle", "fileStyle");
	} catch(e){ log(e); }
}

function onAddSearchSets(form) {
	var importtext;
	var importtype;

	// serialize the metadata selects
	var selects = getChecked(form);

	var $mysets_tab = $('#mysets_tab').tabs();
	var selected = $mysets_tab.tabs('option', 'selected');

	if (selected == 0) {
		$('#mysets_tree').empty().html('<img src="images/ajax-loader.gif" />');
		$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		  {'action':'addsearch',
		   'type':'tree',
		   'searchsets[]': selects }
		);
 	} else if (selected == 1) {
		$('#mysets_flat').empty().html('<img src="images/ajax-loader.gif" />');
		$('#mysets_flat').load('/cgi-bin/BEAST/index.pl', 
		  {'action':'addsearch',
		   'type':'flat',
		   'searchsets[]': selects }
		);
	}
}

function onAddBrowseSets(form) {
	var importtext;
	var importtype;

	// serialize the metadata selects
	var checkedElements = new Array();
	var j = 0;
    	for (var i=0; i < form.browse.length; i++) {
		if (form.browse[i].checked == 1) {
			checkedElements[j] = form.browse[i].value;
			j++;
		}
	}	

	var $mysets_tab = $('#mysets_tab').tabs();
	var selected = $mysets_tab.tabs('option', 'selected');

	if (selected == 0) {
		$('#mysets_tree').empty().html('<img src="images/ajax-loader.gif" />');
		$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		  {'action':'addbrowse',
		   'type':'tree',
		   'browsesets[]': checkedElements }
		);
 	} else if (selected == 1) {
		$('#mysets_flat').empty().html('<img src="images/ajax-loader.gif" />');
		$('#mysets_flat').load('/cgi-bin/BEAST/index.pl', 
		  {'action':'addbrowse',
		   'type':'flat',
		   'browsesets[]': checkedElements }
		);
	}
}

function onAddImportSets(form) {
	var importtext;
	var importtype;

	// serialize the metadata selects
	var selects = getChecked(form);

	var $mysets_tab = $('#mysets_tab').tabs();
	var selected = $mysets_tab.tabs('option', 'selected');

	if (selected == 0) {
		$('#mysets_tree').empty().html('<img src="images/ajax-loader.gif" />');
		$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		  {'action':'addimportfile',
		   'type':'tree',
		   'importsets[]': selects }
		);
 	} else if (selected == 1) {
		$('#mysets_flat').empty().html('<img src="images/ajax-loader.gif" />');
		$('#mysets_flat').load('/cgi-bin/BEAST/index.pl', 
		  {'action':'addimportfile',
		   'type':'flat',
		   'importsets[]': selects }
		);
	}
}

function onImportSets(form) {

	var importtext = document.getElementById('setsImportFromText');
	var importtype = 'text';


	// serialize the metadata selects
	var selects = new Array();
	var j=0;
	for (i=0; i < form.elements.length; i++) {
		if (form.elements[i].type == "select-one") {
			selects[j] = form.elements[i].name+":"+form.elements[i].value;
			j++;
		}	
	}

	$('#import').load('/cgi-bin/BEAST/index.pl', 
		{ action:'import',
		 importtext: importtext.value, 
		 importtype: importtype,
		 'metadata[]': selects }
	);
}

function getSelected(form, selectedOrUnselected) {

	var checkedElements = new Array();
	var j = 0;
    	for (var i=0; i < form.elements.length; i++) {
		if (form.elements[i].type == "checkbox") {
			if (form.elements[i].checked == selectedOrUnselected) {
				checkedElements[j] = form.elements[i].name;
				j++;
			}
		}
	}	

	return checkedElements;
}

function getUnchecked(form) {
	return getSelected(form, 0);
}

function getChecked(form) {
	return getSelected(form, 1);
}

function onUpdateMySets(form) {

	<!-- build search opts data structure -->
	var checkedElements = getChecked(form);

	$('#mysets_tree').empty().html('<img src="images/ajax-loader.gif" />');
	$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		{action:"mysets",
		 type:"tree",
		 'checkedelements[]': checkedElements}
	);

}

function onUpdateMySetsFlat(form) {

	<!-- build search opts data structure -->
	var checkedElements = getChecked(form);

	$('#mysets_flat').empty().html('<img src="images/ajax-loader.gif" />');
	$('#mysets_flat').load('/cgi-bin/BEAST/index.pl', 
		{action:"mysets",
		 type:"flat",
		 'checkedelements[]': checkedElements}
	);

}

function onClearMySets() {

	<!-- build search opts data structure -->

	$('#mysets_tree').empty().html('<img src="images/ajax-loader.gif" />');
	$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		{action:"clear"}
	);

}

function onClearMySetsFlat() {

	<!-- build search opts data structure -->

	$('#mysets_flat').empty().html('<img src="images/ajax-loader.gif" />');
	$('#mysets_flat').load('/cgi-bin/BEAST/index.pl', 
		{action:"clear"}
	);

}

function onSearchSets() {
	var form = document.getElementById('searchcategories');

	var selects = getChecked(form);

	$('#search').empty().html('<img src="images/ajax-loader.gif" />');
	$('#search').load('/cgi-bin/BEAST/index.pl', 
		{action:"search",
		 searchtext: form.searchtext.value, 
		 'checkedfilters[]': selects} 
	);
}

function setCheckboxesOfChildren(htmlElement, checkedState) {
    	for (var i=0; i < htmlElement.children.length; i++) {
		if (htmlElement.children[i].type == "checkbox") {
			htmlElement.children[i].checked = checkedState;	
		} else if (htmlElement.children[i].tagName == 'DIV') {
			setCheckboxesOfChildren(htmlElement.children[i], checkedState);
		} 
	}
}

function updateMetaCheckBox(divID, checkedState) {

	var children = document.getElementById(divID+"_content");	
    	for (var i=0; i < children.children.length; i++) {
		if (children.children[i].type == "checkbox") {
			children.children[i].checked = checkedState;	
		} else if (children.children[i].tagName == 'DIV') {
			setCheckboxesOfChildren(children.children[i], checkedState);
		} 
	}
}

function handleKeypress(e) {
	if (e.which == 13) {
		alert('enter pressed!');
	}
}

// set class
function Set(json) {

	this.name = json._name;
	this.elements = json._elements;
	this.metadata = json._metadata;

	this.getName = function() {
		return this.name;
	}

	this.getElements = function() {
		var elements = new Array();
		for (var index in this.elements) {
			elements.push(index);
		}
		return elements;
	}

	this.display = function() {
		var div = "<div>"+this.name+"</div>";
		return div;
	}

	// binary membership right now
	this.getMembershipValue = function(element) {
		for (var index in this.elements) {
			if (index == element) {
				return true;	
			}
		}
		return false;
	}
}

//Added timestamp (ts) to make sure that html element ids are unique, as the same meta/set id will appear multiple times in this hierarchy.
function toggleChildren(id, depth, ts)
{
	var div_element   = document.getElementById(id + "_" + ts + "_children");
	var arrow_element = document.getElementById(id + "_" + ts + "_arrow");

	//If style.display is "block" or undefined, the element is showing.  Hide it (and show plus)
	if(!div_element.style.display || div_element.style.display == 'block')
	{
		div_element.style.display = 'none';
		arrow_element.src = 'images/plus.png';
	}
	//If style.display is "none", the element is hidden.  set it to "Block" to show it (and show minus)
	else if (div_element.style.display == 'none')
	{
		div_element.style.display = 'block';
		arrow_element.src = 'images/ominus.png';
		if(div_element.loaded)
		{
			//We already loaded these children, no need to reload them
		}
		else
		{
			//Load children...  do this through the index.pl router.  pass the parent_id and the depth of the child
			$("#"+id+"_"+ts+"_children").load('/cgi-bin/BEAST/index.pl', 
				{action:"browse_dig", 
				 parent_id:id, 
				 depth:depth
				},
				function()
				{
					//on success, set a parameter on the div element to say that it is already loaded so that we don't reload in the future.
					var div_element = document.getElementById(id+"_"+ts+"_children");
					div_element.loaded = true;
				}
			);
		}
	}
}

function onSetClick(id, depth, ts)
{
	var div_element   = document.getElementById(id + "_" + ts + "_content");

	//If style.display is "block" or undefined, the element is showing.  Hide it (and show plus)
	if(!div_element.style.display || div_element.style.display == 'block')
	{
		div_element.style.display = 'none';
	}
	//If style.display is "none", the element is hidden.  set it to "Block" to show it (and show minus)
	else if (div_element.style.display == 'none')
	{
		div_element.style.display = 'block';
		if(div_element.loaded)
		{
			//We already loaded these children, no need to reload them
		}
		else
		{
			//Load children...  do this through the index.pl router.  pass the parent_id and the depth of the child
			$("#"+id+"_"+ts+"_content").load('/cgi-bin/BEAST/index.pl', 
				{action:"get_set_elements", 
				 db_id:id, 
				 depth:depth
				},
				function()
				{
					//on success, set a parameter on the div element to say that it is already loaded so that we don't reload in the future.
					var div_element = document.getElementById(id+"_"+ts+"_content");
					div_element.loaded = true;
				}
			);
		}
	}
}

function onImageClick(event) {
	document.imageLock = true;
	var selectedColumnDiv = highlightElement(event);
	highlightRowElement(event, selectedColumnDiv);
}

function onImageHover(event) {
	if (document.imageLock) {
		return;
	}
	highlightElement(event);
}

function highlightRowElement(event, selectedColumnDiv) {
        pos_x = event.offsetX?(event.offsetX):event.pageX-document.getElementById("grid_image_div").offsetLeft;
        pos_y = event.offsetY?(event.offsetY):event.pageY-document.getElementById("pointer_div").offsetTop;

	var rowData = document.getElementById('gif_info_rows').value;
	var data = rowData.split('^');
	
	var row_height = data[0];
	var rows = data[1].split(',');

	var rowIndex = Math.floor(pos_y / row_height);
	var elementName = rows[rowIndex];
	alert('Gene: '+elementName);
}

function highlightElement(event) {
        pos_x = event.offsetX?(event.offsetX):event.pageX-document.getElementById("grid_image_div").offsetLeft;
        pos_y = event.offsetY?(event.offsetY):event.pageY-document.getElementById("pointer_div").offsetTop;
	//$('#mysets_flat').load('/cgi-bin/BEAST/index.pl', 
	//	{action:"column_highlight",
	//	x_coord:pos_x,
	//	y_coord:pos_y
	//	}
	//);

	var colData = document.getElementById('gif_info_columns').value;
	var data = colData.split('^');
	
	var column_width = data[0];
	var columns = data[1].split(',');

	// scroll math
	var scrollDiv = document.getElementById('mysets_flat');
	var scrollSpan = scrollDiv.scrollHeight - scrollDiv.offsetHeight;
	var scrollIncrement = scrollSpan / columns.length;

	var selectedColumnDiv;
	// column math...
	var colIndex = Math.floor(pos_x / column_width);
	try
	{
		var scrollHeight = 0;
		for (var i=0; i < columns.length; i++)
		{
			var div_flat = document.getElementById("mysets_flat"+"<>"+columns[i]);
			if (i == colIndex) {
				selectedColumnDiv = div_flat;	
				div_flat.style.backgroundColor = "yellow";
				scrollDiv.scrollTop = Math.floor(scrollIncrement * i);
			} else {
				div_flat.style.backgroundColor = "white";
			}
		}
	}
	catch (error) 
	{
		//
	}
	return selectedColumnDiv;
}

function getSelectedOption(select) {

	for (var i=0; i < select.options.length; i++) {
		if (select.options[i].selected) {
			return select.options[i];
		}
	}

}

function onUpdateSelectedCollections() {

	var collectionX = document.getElementById('collectionsX');
	var collectionY = document.getElementById('collectionsY');
	
	var optionX = getSelectedOption(collectionX);
	var optionY = getSelectedOption(collectionY);
	
	$.get('/cgi-bin/BEAST/index.pl', 
		{action:"updatecollections",
		 collectionX:optionX.value,
		 collectionY:optionY.value}
	);
}

function onAddCollection(form) {
	// the div
	// the form element is the first child of this div
	var selects = getChecked(form);
	var text_name = document.getElementById('add_collection_name');
	$('#mycollections').empty().html('<img src="images/ajax-loader.gif" />');
	$('#mycollections').load('/cgi-bin/BEAST/index.pl', 
		{action:"addcollection",
		 name:text_name.value,
		 'checkedfilters[]': selects} 
	);
}
