// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var change_rule_type = function(){
	var rule_type = $('#rule_type').val();
	if('RuleDate' == rule_type){
		$('#rule_comp_string').hide();
		$('#rule_date').show();
		//$('#rule_comp_type').attr('options', []);
	}
	else if('RuleAmount' == rule_type){
		$('#rule_comp_string').show();
		$('#rule_date').hide();
	}
	else if('RuleName' == rule_type){
		$('#rule_comp_string').show();
		$('#rule_date').hide();
	}
	
}

var show_filters_dialog = function(){
	$('#filter_dialog').dialog('open');
	return false;
}

var post_form = function(url, form_id, method){
	$.blockUI({message: '<h1>processing...</h1>'}); 
	$('#'+form_id).attr('action', url);
	submitForm(form_id);
}

var toggle_date_selectors = function(){
	if($('#date_selectors').is(':visible')){
		$('#date_selectors').hide();
	}
	else{
		$('#date_selectors').show();
	}
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

function submitForm(form_id){
	$('#'+form_id).submit();
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
	
function click_navigation(button_url, guest){
	if(!guest){
		window.location.href = button_url;
	}
}

function click_navigation_ajax(button_url, current_user){
	
}

function changeContractType(){
	
	var contractType = $('#contract_type').val();
	
	$('#new_contract_full_date').hide();
	$('#new_contract_day_of_month').hide();
	$('#new_contract_day_of_month_alt').hide();
	$('#new_contract_weekday').hide();
	$('#new_contract_date_start').hide();
	$('#new_contract_date_end').hide();
	
	if(contractType == 'ContractYearly'){
		$('#new_contract_full_date').show();
		$('#new_contract_date_start').show();
		$('#new_contract_date_end').show();
	}
	else if(contractType == 'ContractMonthly'){
		$('#new_contract_day_of_month').show();
		$('#new_contract_date_start').show();
		$('#new_contract_date_end').show();
	}
	else if(contractType == 'ContractBimonthly'){
		$('#new_contract_day_of_month').show();
		$('#new_contract_day_of_month_alt').show();
		$('#new_contract_date_start').show();
		$('#new_contract_date_end').show();
	}
	else if(contractType == 'ContractWeekly'){
		$('#new_contract_weekday').show();
		$('#new_contract_date_start').show();
		$('#new_contract_date_end').show();
	}
	else if(contractType == 'ContractOnce'){
		$('#new_contract_full_date').show();
	}
}

function changeTransactionType(){
	
	var contractType = $F('transaction_type');
	
	$('transaction_acount_source_div').hide();
	$('transaction_acount_dest_div').hide();
	
	if(contractType == 'TransactionCredit'){
		$('transaction_acount_source_div').show();
	}
	else if(contractType == 'TransactionDebit'){
		$('transaction_acount_dest_div').show();
	}
	else if(contractType == 'TransactionTransfer'){
		$('transaction_acount_source_div').show();
		$('transaction_acount_dest_div').show();
	}
	
}


function changeTransactionCompleted(){
	var completed = $('transaction_completed').checked;
	if(completed){
		$('transaction_executed_date_div').show();
	}
	else{
		$('transaction_executed_date_div').hide();
	}
}

function changeContractAutopay(){
	var isAutopay = $('new_contract_autopay').select('input:checkbox')[1].checked;
	if(isAutopay){
		$('new_contract_autopay_account').show();
	}
	else{
		$('new_contract_autopay_account').hide();
	}
}

function click_date_text(text_field_id){
	//$(text_field_id).select();
	$(text_field_id + '_calendar_div').show();
	$$('.base_form_field').each(function(inp){
		inp.disable();
	});
	
	
}

function post_hide_calendar(){
	$$('.base_form_field').each(function(inp){
		inp.enable();
	});
}
function select_date(text_field_id){
	$$('.base_form_field').each(function(inp){
		inp.enable();
	});
	var date = new Date($F(text_field_id + '_calendar'));
	year = date.getFullYear();
	month = date.getMonth() + 1;
	day = date.getDate();
	
	$(text_field_id).setValue(year + "-" + (month < 10 ? "0" : "") + month + "-" + (day < 10 ? "0" : "") + day);
	$(text_field_id + '_calendar_div').hide();
}

function select_date_span(text_field_id){
	$$('.base_form_field').each(function(inp){
		inp.enable();
	});
	
	var date = new Date($F(text_field_id + '_calendar'));
	year = date.getFullYear();
	month = date.getMonth() + 1;
	day = date.getDate();
	
	$(text_field_id).setValue(year + "-" + (month < 10 ? "0" : "") + month + "-" + (day < 10 ? "0" : "") + day);
	$(text_field_id + '_calendar_div').hide();
	$('ajax_submit_button').click();
}

function select_date_span_flex(text_field_id_change, start_date_text_field_id, end_date_text_field_id){
	$$('.base_form_field').each(function(inp){
		inp.enable();
	});
	
	var date = new Date($F(text_field_id_change + '_calendar'));
	year = date.getFullYear();
	month = date.getMonth() + 1;
	day = date.getDate();
	
	$(text_field_id_change).setValue(year + "-" + (month < 10 ? "0" : "") + month + "-" + (day < 10 ? "0" : "") + day);
	$(text_field_id_change + '_calendar_div').hide();
	updateDateRange($(start_date_text_field_id).value, $(end_date_text_field_id).value);
}

function updateDateRange(startDateStr, endDateStr){
	
	var flexObj = swfobject.getObjectById("timeline_obj");
  	flexObj.updateDateRange(startDateStr, endDateStr);
}

function getFlexApp(appName){
  	if (navigator.appName.indexOf ("Microsoft") !=-1){
    	return window[appName];
  	}
  	else{
    	return document[appName];
	}
}

var toggle_completed = function(checkboxObj){
	alert("toggle_completed");
  	if(checkboxObj.checked){
  		$('transaction_autopay_checkbox_div').hide();
  		$('transaction_account_select_div').hide();
  	}
  	else{
  		$('transaction_autopay_checkbox_div').show();
  		$('transaction_account_select_div').show();
  	}
};
  
var toggle_autopay = function(checkboxObj){
	alert("toggle_autopay");
  	if(checkboxObj.checked){
  		$('transaction_account_select_div').show();
  	}
  	else{
  		$('transaction_account_select_div').hide();
  	}
};



