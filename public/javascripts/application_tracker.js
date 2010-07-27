// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


var show_filters_dialog = function(){
	$('#filter_dialog').dialog('open');
	return false;
}

var show_reports_columns_dialog = function(){
	$('#columns_dialog').dialog('open');
	return false;
}

var toggleall = function(container_id, flag){
	$('#'+container_id).find(':checkbox').attr('checked', flag);
}

var toggle_checkbox = function(checkbox_obj, flag){
	$('#'+checkbox_obj).attr('checked', flag);
	var link = $(checkbox_obj).next();
	toggle_link(link, flag);
	
}

var toggle_advanced_edit = function(){
	if($('#advanced_toggle').val() == '0'){
		$('.advanced_edit').show();
		$('#advanced_toggle').val('1');
		$('#advanced_toggle_label').html('Hide Avanced');
		
		 $('.advanced_editor').markedit();
	}
	else{
		$('.advanced_edit').hide();
		$('#advanced_toggle').val('0');
		$('#advanced_toggle_label').html('Show Advanced');
	}
}

var toggle_link = function(link_obj, flag){
	if(flag){
		$(link_obj).addClassName("selected_link");
		$(link_obj).removeClassName("unselected_link");
	}
	else{
		$(link_obj).addClassName("unselected_link");
		$(link_obj).removeClassName("selected_link");
	}
	
}
	
var click_checkbox_label = function(container_id, checkbox_id){
	toggleall(container_id, false);
	toggle_checkbox(checkbox_id, true);
}
	
var click_checkbox = function(checkbox_obj){
	toggle_checkbox(checkbox_obj, checkbox_obj.checked);
} 
	
jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} })
	 
	function _ajax_request(url, data, callback, type, method) {
	    if (jQuery.isFunction(data)) {
	        callback = data;
	        data = {};
	    }
	    return jQuery.ajax({
	        type: method,
	        url: url,
	        data: data,
	        success: callback,
	        dataType: type
	        });
	}
	 
	jQuery.extend({
	    put: function(url, data, callback, type) {
	        return _ajax_request(url, data, callback, type, 'PUT');
	    },
	    delete_: function(url, data, callback, type) {
	        return _ajax_request(url, data, callback, type, 'DELETE');
	    }
	});
	 
	jQuery.fn.submitWithAjax = function() {
	  	this.unbind('submit', false);
  		this.submit(function() {
	   		$.post(this.action, $(this).serialize(), null, "script");
	    	return false;
	  	})
	 
	  return this;
	};
	 
	//Send data via get if <acronym title="JavaScript">JS</acronym> enabled
	jQuery.fn.getWithAjax = function() {
	  this.unbind('click', false);
	  this.click(function() {
	    $.get($(this).attr("href"), $(this).serialize(), null, "script");
	    return false;
	  })
	  return this;
	};
	 
	//Send data via Post if <acronym title="JavaScript">JS</acronym> enabled
	jQuery.fn.postWithAjax = function() {
	  this.unbind('click', false);
	  this.click(function() {
	    $.post($(this).attr("href"), $(this).serialize(), null, "script");
	    return false;
	  })
	  return this;
	};
	 
	jQuery.fn.putWithAjax = function() {
	  this.unbind('click', false);
	  this.click(function() {
	    $.put($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
	  })
	  return this;
	};
	 
	jQuery.fn.deleteWithAjax = function() {
	  this.removeAttr('onclick');
	  this.unbind('click', false);
	  this.click(function() {
	    $.delete_($(this).attr("href"), $(this).serialize(), null, "script");
	    return false;
	  })
	  return this;
	};
	 
	//This will "ajaxify" the links
	function ajaxLinks(){
	    $('.ajaxForm').submitWithAjax();
	    $('a.get').getWithAjax();
	    $('a.post').postWithAjax();
	    $('a.put').putWithAjax();
	    $('a.delete').deleteWithAjax();
	}
	 
	$(document).ready(function() {
	 
	// All non-GET requests will add the authenticity token
	  // if not already present in the data packet
	 $(document).ajaxSend(function(event, request, settings) {
	       if (typeof(window.AUTH_TOKEN) == "undefined") return;
	       // <acronym title="Internet Explorer 6">IE6</acronym> fix for http://dev.jquery.com/ticket/3155
	       if (settings.type == 'GET' || settings.type == 'get') return;
	 
	       settings.data = settings.data || "";
	       settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(window.AUTH_TOKEN);
	     });
	 
	  ajaxLinks();
	});