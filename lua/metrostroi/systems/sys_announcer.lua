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
	[1101] = { },
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
	-- Check if new announcement must be started from train wire
	local targetAnnouncement = self.Train:ReadTrainWire(48)
	if (targetAnnouncement > 0) and (targetAnnouncement ~= self.Announcement) and (CurTime() > self.EndTime) then
		self.Announcement = targetAnnouncement
		if Metrostroi.Announcements[targetAnnouncement] then
			self.Sound = Metrostroi.Announcements[targetAnnouncement][2]
			self.EndTime = CurTime() + Metrostroi.Announcements[targetAnnouncement][1]

			-- Emit the sound
			if self.Sound ~= "" then
				self.Train:EmitSound(self.Sound, 85, 100)
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
		self.Train:WriteTrainWire(48,self.ScheduleAnnouncement)
		if CurTime() > (self.ScheduleEndTime or -1e9) then
			self.ScheduleAnnouncement = 0
			self.Train:WriteTrainWire(48,0)
		end
	end
end
