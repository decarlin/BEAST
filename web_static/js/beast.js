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
    for (var i=0; i < form.elements.length; i++) 
    {
        form.elements[i].checked = checked;
    }
}
function onImportFilters() {
	alert("imported!");
}
