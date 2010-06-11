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
