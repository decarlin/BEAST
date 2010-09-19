// alert("common.js front and center");
// mouseOver/Out actions for text
function doMouseOver(e)
{
    e.style.textDecoration = "underline";
}
function doMouseOut(e)
{
    e.style.textDecoration = "none";
}


// mouseOver/Out actions for table rows
function doTRMouseOver(e)
{
	e.backupBGC = e.style.backgroundColor;
    e.style.backgroundColor = "lightyellow";
}
function doTRMouseOut(e)
{
	e.style.backgroundColor = e.backupBGC;
}


//Can probably do this better, but it works for now.  Pulled from a website
function getQueryStringParameter(variable)
{
	var query = window.location.search.substring(1); 
	var vars = query.split("&"); 
	for (var i=0;i<vars.length;i++)
	{ 
		var pair = vars[i].split("="); 
		if (pair[0] == variable)
		{
			return pair[1]; 
		}
	}
	return '';
} 


function getRadioButtonValue(fieldName)
{
    //Check to make sure radio button is selected
    for(var i=0; i<eval("document.forms[0]." + fieldName + ".length"); i++)
    {
        if(eval("document.forms[0]." + fieldName + "[" + i + "].checked"))
        {
            return eval("document.forms[0]." + fieldName + "[" + i + "].value");
        }
    }
    return false;
}

