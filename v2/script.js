
var curpage = 1;
var pages = 0;

function updatearrows()
{
	//Update page number
	$("#right > span").html(curpage);
	
	//Update arrow visibility
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
	updatearrows();
}

function prevpage()
{
	if(curpage == 1)
		return;
		
	$("#page" + curpage).hide();
	curpage = curpage - 1;
	$("#page" + curpage).show();
	updatearrows();
}

$(document).ready(function(){
	//Count pages
	$("div[id*='page']").each(function() {
		pages++;
	})
	
	//Hide pages except first
	for(var i=2;i<=pages;i++)
	{
		$("#page"+i).hide();
	}
});

