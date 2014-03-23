
local needsreloading = true
local schedules = {}
--Todo: Receive schedules
local function ReceiveSchedules()
	schedules = {}
	
	for i=1,5 do
		table.insert(schedules, {
			from = StationNameFromID(math.random(1,100)),
			to = StationNameFromID(math.random(1,100)),
			line = math.random(1,3)
		})
	end
	
	needsreloading = true
end
ReceiveSchedules()

surface.CreateFont( "JobsLineNumber", {
	font = "Arial",
	size = 40,
	weight = 600
})

local frame, pnllist
function OpenJobs()
	if not frame then
		frame = vgui.Create("DFrame")
			frame:SetSize(400, 600)
			frame:Center()
			frame:SetDeleteOnClose(false)
			frame:SetSizable(true)
			frame:SetTitle("Available Schedules")
			frame:MakePopup()
		
		pnllist = vgui.Create("DPanelList", frame)
			pnllist:Dock(FILL)
			pnllist:SetSpacing(2)
	end
	
	if needsreloading then
		pnllist:Clear()
		
		local function CreateSched(from, to, line)
			local pnl = vgui.Create("DPanel")
				pnl:SetTall(60)
				pnl:DockPadding(5,5,5,5)
			
			local linepnl = vgui.Create("DPanel", pnl)
				linepnl:Dock(LEFT)
				linepnl:DockMargin(0,0,5,0)
				linepnl:SetWide(60-10)
				linepnl.line = line
				linepnl.Paint = function(self,w,h)
					derma.GetDefaultSkin().tex.Panels.Normal(0, 0, w, h, LineColorFromID(self.line) )
					
					draw.SimpleText(tostring(self.line), "JobsLineNumber", 25, 25, Color(50,50,50), 1, 1)
				end
				
			local lblfrom = vgui.Create("DLabel", pnl)
				lblfrom:Dock(TOP)
				lblfrom:SetDark(true)
				lblfrom:SetText("From: "..from)
				lblfrom:SizeToContents()
				
			local lblto = vgui.Create("DLabel", pnl)
				lblto:Dock(TOP)
				lblto:SetDark(true)
				lblto:SetText("To: "..to)
				lblto:SizeToContents()
			
			local btn = vgui.Create("DButton", pnl)
				btn:Dock(RIGHT)
				btn:SetZPos(-4)
				btn:SetWide(50)
				btn:SetText("Accept")
			
			pnllist:AddItem(pnl)
		end
		
		for k,v in pairs(schedules) do
			CreateSched(v.from, v.to, v.line)
		end
		
		needsreloading = false
	end
	
	frame:SetVisible(true)
end

concommand.Add("metrostroi_jobs", OpenJobs)
