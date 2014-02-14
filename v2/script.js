
var curpage = 1;
var pages = 4;

function updatearrows()
{
	if(curpage == 1)
	{
		$("#goleft").html(" ");
		$("#goright").html("4");
	}
	else if(curpage == pages)
	{
		$("#goleft").html("3");
		$("#goright").html(" ");
	}
	else
	{
		$("#goleft").html("3");
		$("#goright").html("4");
	}
}

function nextpage()
{
	if(curpage == pages)
		return;
	
	$("#page" + curpage).hide();
	curpage = curpage + 1;
	$("#page" + curpage).show();
	$("#right > span").html(curpage);
	updatearrows();
}

function prevpage()
{
	if(curpage == 1)
		return;
		
	$("#page" + curpage).hide();
	curpage = curpage - 1;
	$("#page" + curpage).show();
	$("#right > span").html(curpage);
	updatearrows();
}

$(document).ready(function(){
	for(var i=2;i<=pages;i++)
	{
		$("#page"+i).hide();
	}
});

