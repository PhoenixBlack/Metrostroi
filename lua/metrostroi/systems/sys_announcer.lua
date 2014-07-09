--------------------------------------------------------------------------------
-- Announcer and announcer-related code
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("Announcer")
TRAIN_SYSTEM.DontAccelerateSimulation = true
if TURBOSTROI then return end

Metrostroi.Announcements = {
	[0001] = { 0.700, "" },
	[0002] = { 1.500, "" },
	[0003] = { 1.123, "subway_announcer/00_03.mp3" },
	[0004] = { 3.109, "subway_announcer/00_04.mp3" },
	[0005] = { 0.940, "subway_announcer/00_05.mp3" },
	[0006] = { 1.149, "subway_announcer/00_06.mp3" },
	
	[0101] = { 2.194, "subway_announcer/01_01.mp3" },
	[0102] = { 1.202, "subway_announcer/01_02.mp3" },
	[0103] = { 2.351, "subway_announcer/01_03.mp3" },
	[0104] = { 1.463, "subway_announcer/01_04.mp3" },
	[0105] = { 8.385, "subway_announcer/01_05.mp3" },
	[0106] = { 4.963, "subway_announcer/01_06.mp3" },
	[0107] = { 4.963, "subway_announcer/01_07.mp3" },
	[0108] = { 7.784, "subway_announcer/01_08.mp3" },
	[0109] = { 4.624, "subway_announcer/01_09.mp3" },
	
	[0201] = { 2.168, "subway_announcer/02_01.mp3" },
	[0202] = { 0.679, "subway_announcer/02_02.mp3" },
	[0203] = { 0.967, "subway_announcer/02_03.mp3" },
	[0204] = { 3.239, "subway_announcer/02_04.mp3" },
	[0205] = { 4.023, "subway_announcer/02_05.mp3" },
	[0206] = { 3.997, "subway_announcer/02_06.mp3" },
	[0207] = { 3.997, "subway_announcer/02_07.mp3" },
	[0208] = { 3.683, "subway_announcer/02_08.mp3" },
	[0209] = { 5.564, "subway_announcer/02_09.mp3" },
	[0210] = { 2.247, "subway_announcer/02_10.mp3" },
	[0211] = { 1.907, "subway_announcer/02_11.mp3" },
	[0212] = { 7.628, "subway_announcer/02_12.mp3" },
	[0213] = { 5.512, "subway_announcer/02_13.mp3" },
	[0214] = { 8.464, "subway_announcer/02_14.mp3" },
	[0215] = { 2.299, "subway_announcer/02_15.mp3" },
	[0216] = { 1.437, "subway_announcer/02_16.mp3" },
	[0217] = { 6.060, "subway_announcer/02_17.mp3" },
	[0218] = { 2.299, "subway_announcer/02_18.mp3" },
	[0219] = { 1.358, "subway_announcer/02_19.mp3" },
	[0220] = { 0.888, "subway_announcer/02_20.mp3" },
	[0221] = { 2.429, "subway_announcer/02_21.mp3" },
	[0222] = { 3.579, "subway_announcer/02_22.mp3" },
	[0223] = { 1.933, "subway_announcer/02_23.mp3" },
	[0224] = { 4.153, "subway_announcer/02_24.mp3" },
	[0225] = { 3.553, "subway_announcer/02_25.mp3" },
	[0226] = { 3.082, "subway_announcer/02_26.mp3" },
	[0227] = { 3.579, "subway_announcer/02_27.mp3" },
	[0228] = { 4.519, "subway_announcer/02_28.mp3" },
	[0229] = { 5.564, "subway_announcer/02_29.mp3" },
	[0230] = { 1.411, "subway_announcer/02_30.mp3" },
	[0231] = { 1.358, "subway_announcer/02_31.mp3" },
	[0232] = { 7.602, "subway_announcer/02_32.mp3" },
	
	[0308] = { 1.228, "subway_announcer/03_08.mp3" },
	[0309] = { 1.358, "subway_announcer/03_09.mp3" },
	[0310] = { 1.228, "subway_announcer/03_10.mp3" },
	[0311] = { 1.228, "subway_announcer/03_11.mp3" },
	[0312] = { 1.358, "subway_announcer/03_12.mp3" },
	[0313] = { 1.358, "subway_announcer/03_13.mp3" },
	[0314] = { 1.097, "subway_announcer/03_14.mp3" },
	[0315] = { 1.176, "subway_announcer/03_15.mp3" },
	[0316] = { 1.149, "subway_announcer/03_16.mp3" },
	[0317] = { 1.698, "subway_announcer/03_17.mp3" },
	[0318] = { 1.123, "subway_announcer/03_18.mp3" },
	[0319] = { 1.280, "subway_announcer/03_19.mp3" },
	[0320] = { 3.709, "subway_announcer/03_20.mp3" },
	[0321] = { 1.489, "subway_announcer/03_21.mp3" },
	[0322] = { 1.358, "subway_announcer/03_22.mp3" },
	[0323] = { 1.384, "subway_announcer/03_23.mp3" },
	
	[0415] = { 1.149, "subway_announcer/04_15.mp3" },

	[9999] = { 3.0,   "subway_announcer/00_00.mp3" },
}

Metrostroi.AnnouncementSequences = {
	[1101] = { 0211, 0308, 0321 },
	[1102] = { 0211, 0321, 0308 },

	[1108] = { 0220, 0308 },
	[1109] = { 0220, 0309 },
	[1110] = { 0220, 0310, 0231 },
	[1111] = { 0220, 0311 },
	[1112] = { 0220, 0312 },
	[1113] = { 0220, 0313 },
	[1114] = { 0220, 0314 },
	[1115] = { 0220, 0315, 0231, 0202, 0203, 0415 },
	[1116] = { 0220, 0316 },
	[1117] = { 0220, 0317 },
	[1118] = { 0220, 0318, 0231 },
	[1119] = { 0220, 0319 },
	[1120] = { },
	[1121] = { 0220, 0321 },
	[1122] = { 0220, 0322 },
	[1123] = { 0220, 0323 },
	
	[1208] = { 0218, 0219, 0308 },
	[1209] = { 0218, 0219, 0309 },
	[1210] = { 0218, 0219, 0310 },
	[1211] = { 0218, 0219, 0311 },
	[1212] = { 0218, 0219, 0312 },
	[1213] = { 0218, 0219, 0313 },
	[1214] = { 0218, 0219, 0314 },
	[1215] = { 0218, 0219, 0315 },
	[1216] = { 0218, 0219, 0316 },
	[1217] = { 0218, 0219, 0317 },
	[1218] = { 0218, 0219, 0318 },
	[1219] = { 0218, 0219, 0319 },
	[1220] = { },
	[1221] = { 0218, 0219, 0321 },
	[1222] = { 0218, 0219, 0322 },
	[1223] = { 0218, 0219, 0323 },
}

Metrostroi.AnnouncementSequenceNames = {
	[1108] = "Avtozavodskaya",
	[1109] = "Industrial'naya",
	[1110] = "Moskovskaya",
	[1111] = "Oktyabrs'kaya",
	[1112] = "Ploschad' Myra",
	[1113] = "Novoarmeyskaya",
	[1114] = "Vokzalnaya",
	[1115] = "Komsomol'skaya",
	[1116] = "Elektrosila",
	[1117] = "Teatral'naya Ploshad",
	[1118] = "Park Pobedy",
	[1119] = "Sineozernaya",
	[1120] = "Lesnaya",
	[1121] = "Minskaya",
	[1122] = "Tsarskiye Vorota",
	[1123] = "Mezhdustroyskaya",
}

-- Quick lookup
for k,v in pairs(Metrostroi.Announcements) do
	v[3] = k
end


--------------------------------------------------------------------------------
function TRAIN_SYSTEM:Initialize()
	for k,v in pairs(Metrostroi.Announcements) do
		util.PrecacheSound(v[2])
	end

	-- Currently playing announcement
	self.Announcement = 0
	-- End time of the announcement
	self.EndTime = -1e9
	-- Announcement schedule
	self.Schedule = {}
	-- Fake wire 49
	self.Fake48 = 0
end


function TRAIN_SYSTEM:Inputs()
	return { "Queue" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	if (name == "Queue") and (value > 0.0) then
		self:Queue(math.floor(value))
    end
end


function TRAIN_SYSTEM:Queue(id)
	if (not Metrostroi.Announcements[id]) and
		(not Metrostroi.AnnouncementSequences[id]) then return end

	-- Add announcement to queue
	if #self.Schedule < 16 then
		if Metrostroi.AnnouncementSequences[id] then
			for k,i in pairs(Metrostroi.AnnouncementSequences[id]) do
				self:Queue(i)
			end
		else
			table.insert(self.Schedule, Metrostroi.Announcements[id])
		end
	end
end


function TRAIN_SYSTEM:ClientThink()
	local active = self.Train:GetNWBool("BPSNBuzz",false)
	self.Train:SetSoundState("bpsn_ann",active and 0.175 or 0,1)
end

function TRAIN_SYSTEM:Think()
	-- Build-in announcer logic
	if self.Train.R_Radio and (self.Train.R_Radio.Value > 0.5) then
		-- Startup
		if self.Radioinformator == 0 then
			self:Queue(0005)
			self:Queue(0201)
			self:Queue(0006)
			self.Radioinformator = 100
			self.Radiotimer = CurTime()+5.0
			
			self.Train:SetNWString("CustomStr2","Prev(Depart)")
			self.Train:SetNWString("CustomStr3","Select")
			self.Train:SetNWString("CustomStr4","")
			self.Train:SetNWString("CustomStr5","Next(Arrive)")
			self.Train:SetNWString("CustomStr6","F1")
			self.Train:SetNWString("CustomStr7","F2")
			self.Train:SetNWString("CustomStr8","F3")
			self.Train:SetNWString("CustomStr9","F4")
			self.Train:SetNWString("CustomStr10","")
			self.Train:SetNWString("CustomStr11","")
			self.Train:SetNWString("CustomStr12","Enable")
			self.Train:SetNWString("CustomStr13","Silent")
		end
		if self.Radioinformator == 100 then
			if (CurTime() > self.Radiotimer) then
				self.Radioinformator = 101
			end
		end
		if self.Radioinformator == 101 then
			self.Radioinformator = 1
			self.SelectedMessage = 1108
			self.Train:SetNWString("CustomStr0","SELECT START STATION")
		end
		-- Select starting station
		if self.Radioinformator == 1 then
			if self.Train.Custom4.Value > 0.5 then
				self.Radioinformator = 91
				self.SelectedMessage = self.SelectedMessage + 1
				if self.SelectedMessage > 1123 then self.SelectedMessage = 1108 end
			end
			if self.Train.Custom1.Value > 0.5 then
				self.Radioinformator = 91
				self.SelectedMessage = self.SelectedMessage - 1
				if self.SelectedMessage < 1108 then self.SelectedMessage = 1123 end
			end
			if self.Train.Custom2.Value > 0.5 then
				self.Radioinformator = 2
				self.Train:SetNWString("CustomStr0","SELECT DIRECTION")
				self.Train:SetNWString("CustomStr1","AVTOZAV -> MINSKAYA")
				self.SelectedDirection = 1
			end
		end
		-- Stop
		if self.Radioinformator == 2 then
			if self.Train.Custom2.Value < 0.5 then
				self.Radioinformator = 3
			end
		end
		-- Select direction
		if self.Radioinformator == 3 then
			if self.Train.Custom1.Value > 0.5 then
				self.Train:SetNWString("CustomStr1","AVTOZAV -> MINSKAYA")
				self.SelectedDirection = 1
				self:Queue(0005)
				self:Queue(1101)
				self:Queue(0006)
				self.Radioinformator = 93
			end
			if self.Train.Custom4.Value > 0.5 then
				self.Train:SetNWString("CustomStr1","MINSKAYA -> AVTOZAV")
				self.SelectedDirection = -1
				self:Queue(0005)
				self:Queue(1102)
				self:Queue(0006)
				self.Radioinformator = 93
			end
			if self.Train.Custom2.Value > 0.5 then
				self.RadioX = 0
				self.Radioinformator = 4
				self.Train:SetNWString("CustomStr0","")
				self.Train:SetNWString("CustomStr1","")
			end
		end
		-- Stop
		if self.Radioinformator == 4 then
			if self.Train.Custom2.Value < 0.5 then
				self.Radioinformator = 5
			end
		end
		-- Working
		if self.Radioinformator == 5 then
			if (self.Train.Custom4.Value > 0.5) then
				if self.Train.CustomC.Value < 0.5 then
					self:Queue(0005)
					self:Queue(self.SelectedMessage)
					self:Queue(0006)
				end
				self.Radioinformator = 95
				self.RadioX = 0
				
				self.SelectedMessage = self.SelectedMessage + self.SelectedDirection
				if self.SelectedMessage == 1120 then self.SelectedMessage = self.SelectedMessage + self.SelectedDirection end
				if self.SelectedMessage > 1123 then self.SelectedMessage = 1108 end
				if self.SelectedMessage < 1108 then self.SelectedMessage = 1123 end
			end
			if (self.Train.Custom1.Value > 0.5) then
				if self.Train.CustomC.Value < 0.5 then
					self:Queue(0005)
					self:Queue(100+self.SelectedMessage)
					self:Queue(0006)
				end
				self.Radioinformator = 95
				self.RadioX = 0
			end
			if self.Train.Custom3.Value > 0.5 then self:Queue(0005) self:Queue(0217) 				self:Queue(0006) self.Radioinformator = 95 self.RadioX = 0 end
			if self.Train.Custom5.Value > 0.5 then self:Queue(0005) self:Queue(0212+12*self.RadioX) self:Queue(0006) self.Radioinformator = 95 self.RadioX = 1 end
			if self.Train.Custom6.Value > 0.5 then self:Queue(0005) self:Queue(0206+self.RadioX)	self:Queue(0006) self.Radioinformator = 95 self.RadioX = 0 end
			if self.Train.Custom7.Value > 0.5 then self:Queue(0005) self:Queue(0208+self.RadioX)	self:Queue(0006) self.Radioinformator = 95 self.RadioX = 1 end
			if self.Train.Custom8.Value > 0.5 then self:Queue(0005) self:Queue(0204+self.RadioX)	self:Queue(0006) self.Radioinformator = 95 self.RadioX = 1 end
		end
		
		-- Return to menu
		if self.Radioinformator == 91 then
			if (self.Train.Custom1.Value < 0.5) and (self.Train.Custom4.Value < 0.5) then
				self.Radioinformator = 1
			end
		end
		if self.Radioinformator == 93 then
			if (self.Train.Custom1.Value < 0.5) and (self.Train.Custom4.Value < 0.5) then
				self.Radioinformator = 3
			end
		end
		if self.Radioinformator == 95 then
			if (self.Train.Custom1.Value < 0.5) and (self.Train.Custom4.Value < 0.5) and (self.Train.Custom3.Value < 0.5) and
				(self.Train.Custom5.Value < 0.5) and (self.Train.Custom6.Value < 0.5) and
				(self.Train.Custom7.Value < 0.5) and (self.Train.Custom8.Value < 0.5) then
				self.Radioinformator = 5
			end
		end
		
		-- Display message
		if self.DisplayedMessage1 ~= self.SelectedMessage then
			self.DisplayedMessage1 = self.SelectedMessage
			self.Train:SetNWString("CustomStr1",
				Format("%04d%s",self.DisplayedMessage1,(Metrostroi.AnnouncementSequenceNames[self.DisplayedMessage1] or "")))
		end
		if self.DisplayedMessage2 ~= self.Announcement then
			self.DisplayedMessage2 = self.Announcement
			if self.DisplayedMessage2 > 0 then
				self.Train:SetNWString("CustomStr0",Format("PLAYING ANN %04d",self.DisplayedMessage2))
			else
				self.Train:SetNWString("CustomStr0","")
			end
		end
	else
		if self.Radioinformator ~= 0 then
			self.Train:SetNWString("CustomStr0","")
			self.Train:SetNWString("CustomStr1","")
			self.Train:SetNWString("CustomStr2","")
			self.Train:SetNWString("CustomStr3","")
			self.Train:SetNWString("CustomStr4","")
			self.Train:SetNWString("CustomStr5","")
			self.Train:SetNWString("CustomStr6","")
			self.Train:SetNWString("CustomStr7","")
			self.Train:SetNWString("CustomStr8","")
			self.Train:SetNWString("CustomStr9","")
			self.Train:SetNWString("CustomStr10","")
			self.Train:SetNWString("CustomStr11","")
			self.Train:SetNWString("CustomStr12","")
			self.Train:SetNWString("CustomStr13","")
		end
		self.Radioinformator = 0
	end
	
	-- Check if new announcement must be started from train wire
	local targetAnnouncement = self.Train:ReadTrainWire(48)
	local onlyCabin = false
	if (targetAnnouncement == 0) then targetAnnouncement = self.Fake48 or 0  onlyCabin = true end
	if (targetAnnouncement > 0) and (targetAnnouncement ~= self.Announcement) and (CurTime() > self.EndTime) then
		self.Announcement = targetAnnouncement
		if Metrostroi.Announcements[targetAnnouncement] then
			self.Sound = Metrostroi.Announcements[targetAnnouncement][2]
			self.EndTime = CurTime() + Metrostroi.Announcements[targetAnnouncement][1]

			-- Emit the sound
			if self.Sound ~= "" then
				if self.Train.DriverSeat and (self.Train.R_G.Value > 0.5) then
					self.Train.DriverSeat:EmitSound(self.Sound, 73, 100)
				end
				if onlyCabin == false then
					self.Train:EmitSound(self.Sound, 85, 100)
				end
				if (self.Announcement == 0206) or 
				   (self.Announcement == 0207) or 
				   (self.Announcement == 0212) or 
				   (self.Announcement == 0221) or 
				   (self.Announcement == 0224) then
					self.Train.AnnouncementToLeaveWagon = true
					self.Train.AnnouncementToLeaveWagonAcknowledged = false
				else
					self.Train.AnnouncementToLeaveWagon = false
				end
			end
			
			-- BPSN buzz
			if targetAnnouncement == 5 then timer.Simple(0.3,function() self.Train:SetNWBool("BPSNBuzz",true) end) end
			if targetAnnouncement == 6 then timer.Simple(0.4,function() self.Train:SetNWBool("BPSNBuzz",false) end) end
			self.BPSNBuzzTimeout = CurTime() + 10.0
		end
	elseif (targetAnnouncement == 0) then
		self.Announcement = 0
	end
	
	-- Buzz timeout 
	if self.BPSNBuzzTimeout and (CurTime() > self.BPSNBuzzTimeout) then
		self.BPSNBuzzTimeout = nil
		self.Train:SetNWBool("BPSNBuzz",false)
	end
	
	-- Check if new announcement must be started from schedule
	if (self.ScheduleAnnouncement == 0) and (self.Schedule[1]) then
		self.ScheduleAnnouncement = self.Schedule[1][3]
		self.ScheduleEndTime = CurTime() + self.Schedule[1][1]
		table.remove(self.Schedule,1)
	end
	
	-- Check if schedule announcement is playing
	if self.ScheduleAnnouncement ~= 0 then
		if self.Train.DriverSeat and (self.Train.R_ZS.Value < 0.5) then
			self.Fake48 = self.ScheduleAnnouncement
		else
			self.Train:WriteTrainWire(48,self.ScheduleAnnouncement)
			self.Fake48 = 0
		end		
		if CurTime() > (self.ScheduleEndTime or -1e9) then
			self.ScheduleAnnouncement = 0
			self.Fake48 = 0
			self.Train:WriteTrainWire(48,0)
		end
	end
end
