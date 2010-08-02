var checked = false;

function onOpsTabSelected(event, ui) {
	if (ui.tab.hash == "#search") {
		onLoadSearch();
	} else if (ui.tab.hash == '#view') {
		onLoadHeatmap();
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
	}
}

function clearSession() {
	$.get('/cgi-bin/BEAST/index.pl', 
		{action:"clear"}
	);
}

function onLoadImport() {
	$('#import').load('/cgi-bin/BEAST/index.pl', 
		{action:"import"}
	);
}

function onLoadBrowse() {
	$('#browse').load('/cgi-bin/BEAST/index.pl', 
		{action:"browse"}
	);
}

function onLoadSearch() {
	$('#search').load('/cgi-bin/BEAST/index.pl', 
		{action:"search"}
	);
}

function onLoadHeatmap() {
	$('#view').empty().html('<img src="images/ajax-loader.gif" />');
	$('#view').load('/cgi-bin/BEAST/index.pl', 
		{action:"heatmap"}
	);
}


function onLoadView() {

	$.getJSON('/cgi-bin/BEAST/index.pl',  { mysets:"yes", format:"json" }, 
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
	$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		{display_mysets_tree:"yes"}
	);
}

function onLoadMySetsFlat(event, ui) {
	$('#mysets_flat').load('/cgi-bin/BEAST/index.pl', 
		{display_mysets_flat:"yes"}
	);
}

function checkAll(formId) {
    if (checked == false)
    {
        checked = true
    }
    else
    {
        checked = false
    }
    var form = document.getElementById(formId);
    for (var i=0; i < form.elements.length; i++) {
        form.elements[i].checked = checked;
    }
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
		$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		  {'addsearch':'yes',
		   'type':'tree',
		   'searchsets[]': selects }
		);
 	} else if (selected == 1) {
		$('#mysets_flat').load('/cgi-bin/BEAST/index.pl', 
		  {'addsearch':'yes',
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
		$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		  {'addbrowse':'yes',
		   'type':'tree',
		   'browsesets[]': checkedElements }
		);
 	} else if (selected == 1) {
		$('#mysets_flat').load('/cgi-bin/BEAST/index.pl', 
		  {'addbrowse':'yes',
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
		$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		  {'addimportfile':'yes',
		   'type':'tree',
		   'importsets[]': selects }
		);
 	} else if (selected == 1) {
		$('#mysets_flat').load('/cgi-bin/BEAST/index.pl', 
		  {'addimportfile':'Yes',
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
		{'import':'yes',
		 'importtext': importtext.value, 
		 'importtype': importtype,
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

	$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		{mysets:"yes",
		 'checkedelements[]': checkedElements}
	);

}

function onClearMySets() {

	<!-- build search opts data structure -->

	$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		{mysets:"clear"}
	);

}

function onSearchSets() {
	var form = document.getElementById('searchcategories');

	<!-- build search opts data structure -->
	var checkedFilters = new Array();
	var j = 0;
    	for (var i=0; i < form.elements.length; i++) {
		if (form.elements[i].type == "checkbox") {
			if (form.elements[i].checked == 1) {
				checkedFilters[j] = form.elements[i].name;
				j++;
			}
		}
	}


	$('#search').load('/cgi-bin/BEAST/index.pl', 
		{action:"search",
		 searchtext: form.searchtext.value, 
		 'checkedfilters[]': checkedFilters} 
	);
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


