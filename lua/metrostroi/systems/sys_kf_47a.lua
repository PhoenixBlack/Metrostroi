--------------------------------------------------------------------------------
-- Ящик резисторов силовых цепей (КФ-47А)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("KF_47A")

function TRAIN_SYSTEM:Initialize()
	self.Resistors = {
		["L12-L13"]	= 1.730,
		
		["P3-P4"]	= 0.144,
		["P4-P5"]	= 0.223,
		["P5-P6"]	= 0.190,
		["P6-P7"]	= 0.223,
		["P7-P8"]	= 0.223,
		["P8-P9"]	= 0.190,
		["P9-P10"]	= 0.144,
		["P10-P11"]	= 0.144,
		["P11-P12"]	= 1.070,
		["P12-P13"]	= 0.485,
		["P1-P3"]	= 0.715,
		["P3-P14"]	= 1.620,
		["P13-P42"]	= 0.285,
		
		["P16-P17"]	= 0.485,
		["P17-P18"]	= 0.120,
		["P18-P19"]	= 0.223,
		["P19-P20"]	= 0.190,
		["P20-P21"]	= 0.223,
		["P21-P22"]	= 0.223,
		["P22-P23"]	= 0.190,
		["P23-P24"]	= 0.144,
		["P24-P25"]	= 0.144,
		["P25-P26"]	= 0.716,
		["P17-P76"]	= 0.246,
		["P76-P27"]	= 1.710,
		
		["L2-L4"]	= 1.140,
		["L24-L39"]	= 1.000,
		["L40-L63"]	= 1.000,
	}
	self.ResistorTemperatures = {
		["P3-P4"]	= "T1",
		["P4-P5"]	= "T1",
		["P5-P6"]	= "T1",
		["P6-P7"]	= "T1",
		["P7-P8"]	= "T1",
		["P8-P9"]	= "T1",
		["P9-P10"]	= "T1",
		["P10-P11"]	= "T1",
		["P11-P12"]	= "T1",
		["P12-P13"]	= "T1",
		["P1-P3"]	= "T1",
		["P3-P14"]	= "T1",
		["P13-P42"]	= "T1",
		
		["P16-P17"]	= "T2",
		["P17-P18"]	= "T2",
		["P18-P19"]	= "T2",
		["P19-P20"]	= "T2",
		["P20-P21"]	= "T2",
		["P21-P22"]	= "T2",
		["P22-P23"]	= "T2",
		["P23-P24"]	= "T2",
		["P24-P25"]	= "T2",
		["P25-P26"]	= "T2",
		["P17-P76"]	= "T2",
		["P76-P27"]	= "T2",
	}
	
	for k,v in pairs(self.Resistors) do
		self[k] = v
	end
end

function TRAIN_SYSTEM:Think(dT)
	-- Temperature coefficient
	local a = 0.0001
	
	-- Update resistances
	if self.Train.Electric then
		for k,v in pairs(self.ResistorTemperatures) do
			local T = self.Train.Electric[v] or 25
			self[k] = self.Resistors[k]+a*(T-25)
			--print(k,T,self.Resistors[k],self[k])
		end
	end
end