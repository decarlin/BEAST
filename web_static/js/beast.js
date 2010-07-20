var checked = false;

function onOpsTabSelected(event, ui) {
	if (ui.tab.hash == "#browse") {
		onLoadBrowse(event, ui);
	} else if (ui.tab.hash == '#view') {
		onLoadView(event, ui);
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

function onLoadBrowse(event, ui) {
	//alert('loaded browse');
}

function onLoadView(event, ui) {
	
	$.getJSON('/cgi-bin/BEAST/index.pl',  { mysets:"yes", format:"json" }, 
		function(data){
			//alert('JSON Data view'+data._name);
			var viewDiv = document.getElementById('view');
	
			// create set objects
			var sets = new Array();
			for (var index in data._elements) {
				sets.push(new Set(data._elements[index]));
			}
			
			var html = "<b>";
			for (var i=0; i < sets.length; i++) {
				var set = sets[i];
				html =  html+"<li>"+set.getName()+"</li>";
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

function onAddBrowseSets(form) {
	var importtext;
	var importtype;

	// serialize the metadata selects
	var selects = getChecked(form);

	var $mysets_tab = $('#mysets_tab').tabs();
	var selected = $mysets_tab.tabs('option', 'selected');

	if (selected == 0) {
		$('#mysets_tree').load('/cgi-bin/BEAST/index.pl', 
		  {'addbrowse':'yes',
		   'type':'tree',
		   'browsesets[]': selects }
		);
 	} else if (selected == 1) {
		$('#mysets_flat').load('/cgi-bin/BEAST/index.pl', 
		  {'addbrowse':'yes',
		   'type':'flat',
		   'browsesets[]': selects }
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


	$('#browse').load('/cgi-bin/BEAST/index.pl', 
		{browse:"yes",
		 searchtext: form.searchtext.value, 
		 'checkedfilters[]': checkedFilters} 
	);
}

function handleKeypress(e) {
	if (e.which == 13) {
		alert('enter pressed!');
	}
}

function Set(json) {

	this.name = json._name;
	this.elements = json._elements;
	this.metadata = json._metadata;

	this.getName = function() {
		return this.name;
	}

	this.display = function() {
		
	}
}


