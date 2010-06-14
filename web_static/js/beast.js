var checked = false;
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
		var file = document.getElementById("setsImportFromFile");
		var text = document.getElementById("setsImportFromText");
		file.disabled = false;
		text.disabled = true;
		file.select();
		file.focus();
		// grey-out the unselected item
		selectStyle("fileStyle", "textStyle");
	} catch(e){ log(e); }
}

function chooseTextImport(form) {
	try {
		form.importType[0].checked = true;
		var file = document.getElementById("setsImportFromFile");
		var text = document.getElementById("setsImportFromText");
		file.disabled = true;
		text.disabled = false;
		text.select();
		text.focus();
		// grey-out the unselected item
		selectStyle("textStyle", "fileStyle");
	} catch(e){ log(e); }
}

function onImportSets() {
	var form = document.getElementById('importform');

	$('#import').load('/cgi-bin/BEAST/sandbox.pl', 
		{'import':'yes',
		 importtext: form.importtext.value }
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

	$('#browse').load('/cgi-bin/BEAST/sandbox.pl', 
		{browse:"yes",
		 searchtext: form.searchtext.value, 
		 'checkedfilters[]': checkedFilters} 
	);
}
