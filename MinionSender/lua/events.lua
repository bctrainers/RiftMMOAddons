Command.Event.Attach(Event.Addon.Startup.End, MinionSender.AE.Init, "Event.Addon.Startup.End - MinionSender.AE.Init")

function MinionSender.CreateEvents ()
	Command.Event.Attach(Event.System.Update.End, MinionSender.AE.EventSystemUpdateEnd, "Event.System.Update.End - MinionSender.AE.EventSystemUpdateEnd")
	Command.Event.Attach(Command.Slash.Register(MinionSenderAddon.identifier), MinionSender.AE.ToggleWindow, MinionSenderAddon.identifier .. " - MinionSender.AE.ToggleWindow")
	Command.Event.Attach(Command.Slash.Register(MinionSender.AE.Command), MinionSender.AE.ToggleWindow, MinionSender.AE.Command .. " - MinionSender.AE.ToggleWindow")
	Command.Event.Attach(Event.Minion.Adventure.Change, MinionSender.AE.UpdateInfo, "Event.Minion.Adventure.Change - MinionSender.AE.UpdateInfo")
end