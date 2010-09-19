function swapDiv(divID)
{
	var div_element = document.getElementById(divID);
	
	//If style.display is "block" or undefined, the element is showing.  Hide it.
	if(!div_element.style.display ||  div_element.style.display == 'block')
	{
		div_element.style.display = 'none';
	}
	//If style.display is "none", the element is hidden.  set it to "Block" to show it.
	else if (div_element.style.display == 'none')
	{
		div_element.style.display = 'block';
	}
}



function swapDiv2(divID, arrowID)
{
	var div_element = document.getElementById(divID);
	var arrow_element = document.getElementById(arrowID);

	//If style.display is "block" or undefined, the element is showing.  Hide it (and make the arrow point right)
	if(!div_element.style.display || div_element.style.display == 'block')
	{
		div_element.style.display = 'none';
		arrow_element.src = 'images/right_arrow.png';
	}
	//If style.display is "none", the element is hidden.  set it to "Block" to show it (and make the arrow point down)
	else if (div_element.style.display == 'none')
	{
		div_element.style.display = 'block';
		arrow_element.src = 'images/down_arrow.png';
	}
}

function swapDivPlusMinus2(divID, arrowID)
{
	var div_element = document.getElementById(divID);
	var arrow_element = document.getElementById(arrowID);

	//If style.display is "block" or undefined, the element is showing.  Hide it (and make the arrow point right)
	if(!div_element.style.display || div_element.style.display == 'block')
	{
		div_element.style.display = 'none';
		arrow_element.src = 'images/plus.png';
	}
	//If style.display is "none", the element is hidden.  set it to "Block" to show it (and make the arrow point down)
	else if (div_element.style.display == 'none')
	{
		div_element.style.display = 'block';
		arrow_element.src = 'images/ominus.png';
	}
}
