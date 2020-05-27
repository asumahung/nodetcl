function chpwd()
	{
	var newuid = "newuid";
	var oldpwd = "oldpwd";
	var newpwd = "newpwd";
	var email = "email";
	var ip1 = "ip1";
	var ip2 = "ip2";
	
	var url = 'cgi-bin/forcePassword.cgi';
	$.ajax({
		url: url,
		type: 'POST',
		dataType: 'script',
		data: {newuid:newuid,oldpwd:oldpwd,newpwd:newpwd,ip1:ip1,ip2:ip2,email:email},
		success: function(response, textStatus, xhr)
			{
			alert(response);
			},
		error: function(xhr, textStatus, errorThrown)
			{
			alert(xhr);
			}
		}); 
	}

function test()
	{
	var form = document.getElementById('testForm');
	form.submit();
	}

$(document).ready(function() {
    chpwd();
	//test();
	});