//alert("ajaxHelper.js front and center");

//snow is shorthand for string_now.  It returns a timestamp string to tack on the end of URL's to prevent browser cacheing issues
function snow()
{
    var datenow = new Date();
    return escape(datenow.toGMTString());
}

function jq(myid)
{
	return '#' + myid.replace(/(:|\.)/g,'\\$1');
}

function updateDiv(div_name, div_url, div_qs)
{

    //alert(div_name + "\n" + div_url);
    
    // the second parameter to load is an anonymous object (think JSON) of name:value pairs that 
    // can be parsed on the server from the httpRequest
//	$("div#"+div_name).load(div_url, { blah : div_qs });

	$(jq(div_name)).load(div_url);
}


function clearDiv(div_name)
{
//	document.getElementById(div_name).innerHTML = "";	
	$(jq(div_name)).html("");

// these don't work
//	$(jq(div_name)).val("");
//	$(jq(div_name)).innerHTML = "";

}


function doDone() {  }

