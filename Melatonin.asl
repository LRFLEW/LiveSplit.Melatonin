state("Melatonin") { }

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");

    settings.Add("start", true, "Automatically Start Timer when Starting Tutorial");
    settings.Add("remix", true, "Automatically Split on Mashup Completion");
    settings.Add("normal", true, "Automatically Split on Scored Completion");
    settings.Add("hard", true, "Automatically Split on Hard Mode Completion");
    settings.Add("achieve", false, "Automatically Split on Honor Roll and Creator Achievements");
    settings.Add("two", false, "Only Split on Two+ Star Completions");
    settings.Add("three", false, "Only Split on Three Star Completions");
    settings.Add("perfect", false, "Only Split on Perfect Completions");
}

init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        vars.Helper["gameModeQueued"] = mono.Make<int>("Dream", "gameModeQueued");
        vars.Helper["playerDataOff"] = mono.Make<IntPtr>("SaveManager", "playerData");

        return true;
    });
}

update
{
    if (current.playerDataOff != IntPtr.Zero) {
        current.cn = vars.Helper.Read<int>(current.playerDataOff + 0x40);
        current.scores = vars.Helper.ReadSpan<int>(42, current.playerDataOff + 0x44);
        current.achieves = vars.Helper.ReadSpan<byte>(2, current.playerDataOff + 0x17);
    }
}

start
{
    return settings["start"] && current.cn == -1 && old.gameModeQueued != 5 && current.gameModeQueued == 5;
}

split
{
    int thresh = settings["perfect"] ? 4 : settings["three"] ? 3 : settings["two"] ? 2 : 1;
    for (int i=0; i < 42; ++i) {
        bool enabled = i % 2 == 1 ? settings["hard"] : i % 10 == 8 || i == 41 ? settings["remix"] : settings["normal"];
        if (enabled && old.scores[i] < thresh && current.scores[i] >= thresh) return true;
    }
    for (int i=0; i < 2; ++i) {
        if (settings["achieve"] && old.achieves[i] == 0 && current.achieves[i] != 0) return true;
    }
    return false;
}
