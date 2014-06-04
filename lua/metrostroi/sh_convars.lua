--Not sure about the quirks related to shared convars like this
CreateConVar("metrostroi_train_requirethirdrail",1,FCVAR_ARCHIVE,"Whether or not Metrostroi trains require power from the third rail")
CreateConVar("metrostroi_debugger_update_interval",1,FCVAR_ARCHIVE,"Seconds between debugger data messages")

CreateConVar("metrostroi_passengers_scale",50,FCVAR_ARCHIVE)
CreateConVar("metrostroi_arsmode",1,FCVAR_ARCHIVE)
CreateConVar("metrostroi_arsmode_nogreen",0,FCVAR_ARCHIVE)


if SERVER then return end

CreateClientConVar("metrostroi_stop_helper",0,true)

CreateClientConVar("metrostroi_drawdebug",0,true)
CreateClientConVar("metrostroi_debugger_data_timeout",2,true,false)

CreateClientConVar("metrostroi_tooltip_delay",0,true)