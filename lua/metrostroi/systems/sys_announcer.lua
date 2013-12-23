Metrostroi.DefineSystem("Announcer")

Metrostroi.Announcements = {
  [0001] = { 2.1 + 1.5, "subway_announcer/00_01.mp3" },
  [0002] = { 1.1 + 0.0, "subway_announcer/00_02.mp3" },
  [0003] = { 0.7,       "" },
  [0004] = { 1.5,       "" },
  
  [0101] = { 2.2 + 1.5, "subway_announcer/01_01.mp3" },
  [0102] = { 1.4 + 0.0, "subway_announcer/01_02.mp3" },
  [0201] = { 8.0 + 1.5, "subway_announcer/02_01.mp3" },
  [0202] = { 4.7 + 1.5, "subway_announcer/02_02.mp3" },
  [0203] = { 4.7 + 1.5, "subway_announcer/02_03.mp3" },
  [0204] = { 7.5 + 1.5, "subway_announcer/02_04.mp3" },
  [0205] = { 4.4 + 1.5, "subway_announcer/02_05.mp3" },
  
  [0501] = { 1.8 + 0.7, "subway_announcer/05_01.mp3" },
  [0502] = { 2.1 + 0.7, "subway_announcer/05_02.mp3" },
  [0503] = { 2.7 + 0.0, "subway_announcer/05_03.mp3" },
  [0504] = { 5.5 + 0.0, "subway_announcer/05_04.mp3" },
  [0505] = { 4.4 + 0.0, "subway_announcer/05_05.mp3" },
  [0506] = { 1.2 + 0.0, "subway_announcer/05_06.mp3" },
  [0507] = { 0.6 + 0.0, "subway_announcer/05_07.mp3" },
  [0508] = { 1.4 + 0.0, "subway_announcer/05_08.mp3" },

  [0608] = { 1.5 + 0.0, "subway_announcer/06_08.mp3" },
  [0609] = { 1.4 + 0.0, "subway_announcer/06_09.mp3" },
  [0610] = { 1.1 + 0.0, "subway_announcer/06_10.mp3" },
  [0611] = { 1.4 + 0.0, "subway_announcer/06_11.mp3" },
  [0612] = { 1.4 + 0.0, "subway_announcer/06_12.mp3" },
  [0613] = { 1.8 + 0.0, "subway_announcer/06_13.mp3" },
  [0614] = { 1.2 + 0.0, "subway_announcer/06_14.mp3" },
  [0615] = { 1.3 + 0.0, "subway_announcer/06_15.mp3" },
  [0616] = { 1.2 + 0.0, "subway_announcer/06_16.mp3" },
  [0617] = { 1.7 + 0.0, "subway_announcer/06_17.mp3" },
  [0618] = { 1.0 + 0.0, "subway_announcer/06_18.mp3" },
  [0619] = { 1.4 + 0.0, "subway_announcer/06_19.mp3" },
  [0620] = { 2.2 + 0.0, "subway_announcer/06_20.mp3" },
  [0621] = { 0.9 + 0.0, "subway_announcer/06_21.mp3" },
  [0622] = { 2.1 + 0.0, "subway_announcer/06_22.mp3" },
  [0623] = { 1.8 + 0.0, "subway_announcer/06_23.mp3" },

  [0715] = { 1.1 + 0.0, "subway_announcer/07_15.mp3" },

  [0801] = { 3.1 + 0.0, "subway_announcer/08_01.mp3" },
  
  [1101] = { 3.3 + 0.0, "subway_announcer/11_01b.mp3" },
  [1102] = { 1.6 + 0.0, "subway_announcer/11_02b.mp3" },
  [1103] = { 1.3 + 0.0, "subway_announcer/11_03b.mp3" },
  [1104] = { 7.0 + 0.0, "subway_announcer/11_04b.mp3" },
  [1105] = { 2.6 + 0.0, "subway_announcer/11_05b.mp3" },
  [1106] = { 5.8 + 0.0, "subway_announcer/11_06b.mp3" },
  [1107] = { 4.1 + 0.0, "subway_announcer/11_07b.mp3" },
  [1108] = { 1.0 + 0.0, "subway_announcer/11_08.mp3"  },

  [1208] = { 1.2 + 0.0, "subway_announcer/12_08b.mp3" },
  [1209] = { 1.2 + 0.0, "subway_announcer/12_09b.mp3" },
  [1210] = { 1.0 + 0.0, "subway_announcer/12_10b.mp3" },
  [1211] = { 1.0 + 0.0, "subway_announcer/12_11b.mp3" },
  [1212] = { 1.0 + 0.0, "subway_announcer/12_12b.mp3" },
  [1213] = { 1.1 + 0.0, "subway_announcer/12_13b.mp3" },
  [1214] = { 1.0 + 0.0, "subway_announcer/12_14b.mp3" },
  [1215] = { 1.2 + 0.0, "subway_announcer/12_15b.mp3" },
  [1216] = { 1.2 + 0.0, "subway_announcer/12_16b.mp3" },
  [1217] = { 1.2 + 0.0, "subway_announcer/12_17b.mp3" },
  [1218] = { 1.0 + 0.0, "subway_announcer/12_18b.mp3" },
  [1219] = { 1.2 + 0.0, "subway_announcer/12_19b.mp3" },
  [1220] = { 2.2 + 0.0, "subway_announcer/12_20b.mp3" },
  [1221] = { 1.3 + 0.0, "subway_announcer/12_21b.mp3" },
  [1222] = { 1.3 + 0.0, "subway_announcer/12_22b.mp3" },
  [1223] = { 1.5 + 0.0, "subway_announcer/12_23b.mp3" },

  [1315] = { 1.2 + 0.0, "subway_announcer/13_15b.mp3" },
  
  [9999] = { 3.0,       "subway_announcer/00_00.mp3" },
}

Metrostroi.AnnouncementSequences = {
  [0908] = { 0506, 0608 },
  [0909] = { 0506, 0609, 0003, 0505, 0003, 0503 },
  [0910] = { 0506, 0610 },
  [0911] = { 0506, 0611 },
  [0912] = { 0506, 0612 },
  [0913] = { 0506, 0613 },
  [0914] = { 0506, 0614 },
  [0915] = { 0506, 0615 },
  [0916] = { 0506, 0616, 0003, 0504 },
  [0917] = { 0506, 0617 },
  [0918] = { 0506, 0618 },
  [0919] = { 0506, 0619 },
  [0920] = { 0506, 0620 },
  [0921] = { 0506, 0621 },
  [0922] = { 0506, 0622 },
  [0923] = { 0506, 0623 },
  
  [1008] = { 0501, 0508, 0608 },
  [1009] = { 0501, 0508, 0609 },
  [1010] = { 0501, 0508, 0610 },
  [1011] = { 0501, 0508, 0611 },
  [1012] = { 0501, 0508, 0612 },
  [1013] = { 0501, 0508, 0613 },
  [1014] = { 0501, 0508, 0614 },
  [1015] = { 0501, 0508, 0615 },
  [1016] = { 0501, 0508, 0616 },
  [1017] = { 0501, 0508, 0617 },
  [1018] = { 0501, 0508, 0618 },
  [1019] = { 0501, 0508, 0619 },
  [1020] = { 0501, 0508, 0620 },
  [1021] = { 0501, 0508, 0621 },
  [1022] = { 0501, 0508, 0622 },
  [1023] = { 0501, 0508, 0623 },
  
  [1408] = { 1208 },
  [1409] = { 1209, 0004, 1102 },
  [1410] = { 1210 },
  [1411] = { 1211 },
  [1412] = { 1212 },
  [1413] = { 1213 },
  [1414] = { 1214 },
  [1415] = { 1215 },
  [1416] = { 1216, 0004, 1102 },
  [1417] = { 1217 },
  [1418] = { 1218 },
  [1419] = { 1219 },
  [1420] = { 1220 },
  [1421] = { 1221 },
  [1422] = { 1222 },
  [1423] = { 1223 },
  
  [1508] = { 1101, 1103, 1208 },
  [1509] = { 1101, 1103, 1209 },
  [1510] = { 1101, 1103, 1210 },
  [1511] = { 1101, 1103, 1211 },
  [1512] = { 1101, 1103, 1212 },
  [1513] = { 1101, 1103, 1213 },
  [1514] = { 1101, 1103, 1214 },
  [1515] = { 1101, 1103, 1215 },
  [1516] = { 1101, 1103, 1216 },
  [1517] = { 1101, 1103, 1217 },
  [1518] = { 1101, 1103, 1218 },
  [1519] = { 1101, 1103, 1219 },
  [1520] = { 1101, 1103, 1220 },
  [1521] = { 1101, 1103, 1221 },
  [1522] = { 1101, 1103, 1222 },
  [1523] = { 1101, 1103, 1223 },

  [1601] = { 1108, 0909 },
  [1602] = { 1108, 1010, 0004, 0201 },
  [1603] = { 1108, 0910 },
  [1604] = { 1108, 1011 },
  [1605] = { 1108, 0911, 1104 },
  [1606] = { 1108, 1012 },
  [1607] = { 1108, 0912, 0004, 0202 },
  [1608] = { 1108, 1013, 0004, 0204 },
  [1609] = { 1108, 0913, 0004, 0203 },
  [1610] = { 1108, 1014, 0004, 0201 },
  [1611] = { 1108, 0914, 0004, 0202 },
  [1612] = { 1108, 1015 },
  [1613] = { 1108, 0915 },
  [1614] = { 1108, 1016 },
  [1615] = { 1108, 0916 },

  [1616] = { 1108, 0916 },
  [1617] = { 1108, 1015, 0004, 0204 },
  [1618] = { 1108, 0915 },
  [1619] = { 1108, 1014 },
  [1620] = { 1108, 0914, 0004, 0203 },
  [1621] = { 1108, 1013 },
  [1622] = { 1108, 0913, 0004, 0202 },
  [1623] = { 1108, 1012, 0004, 0201 },
  [1624] = { 1108, 0912 },
  [1625] = { 1108, 1011, 0004, 0204 },
  [1626] = { 1108, 0911, 0004, 0201 },
  [1627] = { 1108, 1010 },
  [1628] = { 1108, 0910, 0004, 0203 },
  [1629] = { 1108, 1009 },
  [1630] = { 1108, 0909 },
  
  [1701] = { 1108, 1209 },
  [1702] = { 1108, 1510, 0004, 0201 },
  [1703] = { 1108, 1410 },
  [1704] = { 1108, 1511 },
  [1705] = { 1108, 1411, 1104 },
  [1706] = { 1108, 1512 },
  [1707] = { 1108, 1412, 0004, 0202 },
  [1708] = { 1108, 1513, 0004, 0204 },
  [1709] = { 1108, 1413, 0004, 0203 },
  [1710] = { 1108, 1514, 0004, 0201 },
  [1711] = { 1108, 1414, 0004, 0202 },
  [1712] = { 1108, 1515 },
  [1713] = { 1108, 1415 },
  [1714] = { 1108, 1516 },
  [1715] = { 1108, 1416 },

  [1716] = { 1108, 1416 },
  [1717] = { 1108, 1515, 0004, 0204 },
  [1718] = { 1108, 1415 },
  [1719] = { 1108, 1514 },
  [1720] = { 1108, 1414, 0004, 0203 },
  [1721] = { 1108, 1513 },
  [1722] = { 1108, 1413, 0004, 0202 },
  [1723] = { 1108, 1512, 0004, 0201 },
  [1724] = { 1108, 1412 },
  [1725] = { 1108, 1511, 0004, 0204 },
  [1726] = { 1108, 1411, 0004, 0201 },
  [1727] = { 1108, 1510 },
  [1728] = { 1108, 1410, 0004, 0203 },
  [1729] = { 1108, 1509 },
  [1730] = { 1108, 1409 },
}

Metrostroi.AnnouncementSequences[999] = {1101, 1102, 1103, 1104, 1105, 1106, 1107 }

function TRAIN_SYSTEM:Initialize()
  for k,v in pairs(Metrostroi.Announcements) do
    util.PrecacheSound(v[2])
    v[3] = k
  end

  self.AnnouncementSchedule = {}
  self.CurrentAnnouncement = nil
end

function TRAIN_SYSTEM:Queue(id)
  if (not Metrostroi.Announcements[id]) and
     (not Metrostroi.AnnouncementSequences[id]) then return end

  -- Add announcement to queue
  if #self.AnnouncementSchedule < 10 then
    if Metrostroi.AnnouncementSequences[id] then
      for k,i in pairs(Metrostroi.AnnouncementSequences[id]) do
        self:Queue(i)
        --table.insert(self.AnnouncementSchedule, Metrostroi.Announcements[i])
      end
    else
      table.insert(self.AnnouncementSchedule, Metrostroi.Announcements[id])
    end
  end
end

function TRAIN_SYSTEM:Play(id)
  if (not Metrostroi.Announcements[id]) and
     (not Metrostroi.AnnouncementSequences[id]) then return end

  -- Clear queue and add message to it
  self.AnnouncementSchedule = {}
  self:Queue(id)
end

function TRAIN_SYSTEM:Think()
  -- Check if announcement ended
  if (self.CurrentAnnouncement) and
     (self.AnnouncementEndTime) and
     (CurTime() > self.AnnouncementEndTime) then
    self.CurrentAnnouncement = nil
    self.AnnouncementSound = nil
    self.AnnouncementEndTime = nil
  end

  -- Get play sound from master announcer
  if self.Train.MasterTrain and self.Train.MasterTrain:IsValid() then
    local announcer = self.Train.MasterTrain.Announcer
    if (not self.AnnouncementSound) and
       (announcer.AnnouncementEndTime) and
       (CurTime() < announcer.AnnouncementEndTime-0.5) then
      self.AnnouncementSound   = announcer.AnnouncementSound
      self.AnnouncementEndTime = announcer.AnnouncementEndTime
      self.CurrentAnnouncement = announcer.CurrentAnnouncement
      
      if self.AnnouncementSound and (self.AnnouncementSound ~= "") then
        self.Train:EmitSound(self.AnnouncementSound, 75, 100)
      end
    end
  end

  -- Check if new one must be played
  if (not self.CurrentAnnouncement) and (self.AnnouncementSchedule[1]) then
    self.CurrentAnnouncement = self.AnnouncementSchedule[1]
    table.remove(self.AnnouncementSchedule,1)

    self.AnnouncementEndTime = CurTime() + self.CurrentAnnouncement[1]
    self.AnnouncementSound = self.CurrentAnnouncement[2]
    if self.CurrentAnnouncement[2] ~= "" then
      self.Train:EmitSound(self.CurrentAnnouncement[2], 70, 100)
    end
  end
end
