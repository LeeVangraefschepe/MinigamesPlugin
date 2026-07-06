package com.example.minigamesplugin;

import org.bukkit.plugin.java.JavaPlugin;

public final class MinigamesPlugin extends JavaPlugin {

    @Override
    public void onEnable() {
        getLogger().info("MinigamesPlugin enabled");
    }

    @Override
    public void onDisable() {
        getLogger().info("MinigamesPlugin disabled");
    }
}
