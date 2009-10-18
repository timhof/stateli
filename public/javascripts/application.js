// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



function click_navigation(button_url, guest){
	if(!guest){
		window.location.href = button_url;
	}
}

function click_navigation_ajax(button_url, current_user){
	
}

function changeContractType(){
	
	var contractType = $F('contract_type');
	
	$('new_contract_full_date').hide();
	$('new_contract_day_of_month').hide();
	$('new_contract_day_of_month_alt').hide();
	$('new_contract_weekday').hide();
	$('new_contract_date_start').hide();
	$('new_contract_date_end').hide();
	
	if(contractType == 'ContractYearly'){
		$('new_contract_full_date').show();
		$('new_contract_date_start').show();
		$('new_contract_date_end').show();
	}
	else if(contractType == 'ContractMonthly'){
		$('new_contract_day_of_month').show();
		$('new_contract_date_start').show();
		$('new_contract_date_end').show();
	}
	else if(contractType == 'ContractBimonthly'){
		$('new_contract_day_of_month').show();
		$('new_contract_day_of_month_alt').show();
		$('new_contract_date_start').show();
		$('new_contract_date_end').show();
	}
	else if(contractType == 'ContractWeekly'){
		$('new_contract_weekday').show();
		$('new_contract_date_start').show();
		$('new_contract_date_end').show();
	}
	else if(contractType == 'ContractOnce'){
		$('new_contract_full_date').show();
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
function toggleInstruction(instruction){
  	var inst_div = $(instruction + '_instruction');
  	if(inst_div.visible()){
  		inst_div.hide();
  	}
  	else{
  		inst_div.show();
  	}
}

