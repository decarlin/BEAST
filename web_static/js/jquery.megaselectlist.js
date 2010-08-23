(function($)
{
	// This script was written by Steve Fenton
	// hlttp://www.stevefenton.co.uk/Content/Jquery-Mega-Select-List/
	// Feel free to use this jQuery Plugin
	
	var nextModifierNumber = 0;

	jQuery.fn.megaselectlist = function (settings) {
	
		var config = { "headers": "rel" };
		var classModifier = "megaselectlist";
		
		if (settings) $.extend(config, settings);

		return this.each(function () {
			nextModifierNumber++;
			var originalId = jQuery(this).attr("id");
			var originalName = jQuery(this).attr("name");
			var label = jQuery("label[for='" + originalId + "']");
			var labelText = jQuery(label).text();
			var selectedValue = jQuery(this).val();
			
			if (labelText == "") {
				label = jQuery(this).parents("label");
				labelText = jQuery(label).clone().children().remove().end().text();
			}
			
			var replacementHtml = '<div id="' + classModifier + nextModifierNumber +'" class="' + classModifier + '">' +
				'<p>' + labelText + ': <span></span></p>' +
				'<div class="' + classModifier + 'options">';
			
			var currentHeader = "";
			var isHeaderOpen = false;
			var header = "";
			var options;
			var i;
			
			var optgroups = jQuery(this).children("optgroup");
			
			// If optgroups exist, use them rather than attributes
			if (optgroups.length > 0) {
			
				for (var og = 0; og < optgroups.length; og++) {
					header = jQuery(optgroups[og]).attr("label");
					options = jQuery(optgroups[og]).children("option");
					replacementHtml += '<div class="' + classModifier + 'column"><h2>' + header + '</h2><ul>';
					
					for (i = 0; i < options.length; i++) {
						replacementHtml += '<li rel="' + jQuery(options[i]).val() + '">' + jQuery(options[i]).text() + '</li>';
					}
					replacementHtml += '</ul></div>';
				}
				
			} else {
			
				options = jQuery(this).children("option");
				for (i = 0; i < options.length; i++) {
					header = jQuery(options[i]).attr(config.headers);
					
					if (header != currentHeader) {
						currentHeader = header;
						if (isHeaderOpen) {
							replacementHtml += '</ul></div>';
						}
						isHeaderOpen = true;
						replacementHtml += '<div class="' + classModifier + 'column"><h2>' + header + '</h2><ul>';
					}
				
					replacementHtml += '<li rel="' + jQuery(options[i]).val() + '">' + jQuery(options[i]).text() + '</li>';
				}
				if (isHeaderOpen) {
					replacementHtml += '</ul></div>';
				}
				
			}
			
			// The form element to contain the selected value
			replacementHtml += '<input type="hidden" name="' + originalName + '" id="' + originalId + '" value="' + selectedValue + '">' +
				'<div style="clear: both">&nbsp;</div></div>';

			jQuery(this).remove();
			jQuery(label).hide().after(replacementHtml);
			jQuery(label).remove();
			
			jQuery("#" + classModifier + nextModifierNumber + " li[rel='" + selectedValue + "']").addClass("currentitem");
			
			// Set span to show current selection
			var spanText = jQuery("#" + classModifier + nextModifierNumber + " li.currentitem").text();
			jQuery("#" + classModifier + nextModifierNumber + " span").text(spanText);
			
			jQuery("#" + classModifier + nextModifierNumber + " li").click(function () {
				var item = jQuery(this);
				var thisValue = jQuery(item).attr("rel");
				
				// Set selected value on form
				jQuery("#" + originalId).val(thisValue);
				
				// Set selected class on item
				jQuery(item).parents("." + classModifier).find(".currentitem").removeClass("currentitem");
				jQuery(item).addClass("currentitem");
				
				// Set span to show current selection
				spanText = jQuery(item).parent().parent().parent().find(".currentitem").text();
				jQuery(item).parents("." + classModifier).find("span").text(spanText);
				
				return false;
			});
		});
	};
})(jQuery);
