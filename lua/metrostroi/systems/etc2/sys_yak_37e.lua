--------------------------------------------------------------------------------
-- Ящик с контакторами (ЯК-37К)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("YAK_37E")

function TRAIN_SYSTEM:Initialize()
	-- КШ1, КШ2 (ослабление возбуждения тяговых электродвигателей)
	self.Train:LoadSystem("KSH1","Relay","KPP-113")
	self.Train:LoadSystem("KSH2","Relay","KPP-113")
	
	-- КПП (комутация первичного инвертора БПСН)
	self.Train:LoadSystem("KPP","Relay","KPP-113")
	-- КВП (комутация вторичного инвертора БПСН)
	self.Train:LoadSystem("KVP","Relay","KPD-110","KPP")
	
	-- КСБ1, КСБ2 (включение тиристорных ключей регулирования поля для тормозных режимов)
	self.Train:LoadSystem("KSB1","Relay","KPP-113")
	self.Train:LoadSystem("KSB2","Relay","KPP-113")
	
	-- РРП2 (подача напряжения в цепь управления при резервном пуске)
	self.Train:LoadSystem("RRP2","Relay","KPD-110")
	-- РЗП (защита первичного инвертора БПСН)
	self.Train:LoadSystem("RZP","Relay","REM-651D")
	-- ТР1 (переключение в цепях управления для перехода на тормозной режим)
	self.Train:LoadSystem("TR1","Relay","RPUZ-114-T-UHLZA")
end

function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:Outputs()
	return { }
end

function TRAIN_SYSTEM:TriggerInput(name,value)	
	
end

function TRAIN_SYSTEM:Think()

end
