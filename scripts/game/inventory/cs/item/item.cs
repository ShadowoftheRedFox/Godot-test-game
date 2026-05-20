using System;
using System.Collections.Generic;
using Godot;

namespace Items
{
    public abstract class AbstractItem(
        string Name,
        AbstractItem.ItemClass Class,
        AbstractItem.ItemRarity Rarity
    )
    {
        public enum ItemClass
        {
            UNSCPECIFIED,
            BUILDING,
            TOOL,
        }

        public enum ItemRarity
        {
            UNSCPECIFIED,

            COMMON,
            UNCOMMON,
            RARE,
            EPIC,
            LEGENDARY,
            MYTHIC,
            GODLIKE,
            UNIQUE,
        }

        public const float RARITY_COLOR_ALPHA = 0.6f;
        public readonly Dictionary<ItemRarity, Color> RARITY_COLOR = new()
        {
            // Color.HOT_PINK,
            { ItemRarity.UNSCPECIFIED, new Color(1, 0.4117647f, 0.7058824f, RARITY_COLOR_ALPHA) },
            // Color.WHITE,
            { ItemRarity.COMMON, new Color(1, 1, 1, RARITY_COLOR_ALPHA) },
            // Color.SKY_BLUE,
            {
                ItemRarity.UNCOMMON,
                new Color(0.5294118f, 0.80784315f, 0.92156863f, RARITY_COLOR_ALPHA)
            },
            // Color.BLUE,
            { ItemRarity.RARE, new Color(0, 0, 1, RARITY_COLOR_ALPHA) },
            // Color.PURPLE,
            { ItemRarity.EPIC, new Color(0.627451f, 0.1254902f, 0.9411765f, RARITY_COLOR_ALPHA) },
            // Color.GOLDENROD,
            {
                ItemRarity.LEGENDARY,
                new Color(0.85490197f, 0.64705884f, 0.1254902f, RARITY_COLOR_ALPHA)
            },
            // Color.RED,
            { ItemRarity.MYTHIC, new Color(1, 0, 0, RARITY_COLOR_ALPHA) },
            // Color.DARK_RED,
            { ItemRarity.GODLIKE, new Color(0.54509807f, 0, 0, RARITY_COLOR_ALPHA) },
            // Color.GREEN,
            { ItemRarity.UNIQUE, new Color(0, 1, 0, RARITY_COLOR_ALPHA) },
        };

        [Export]
        public string Name { get; set; } = Name;

        [Export]
        public ItemClass Class { get; set; } = Class;

        [Export]
        public ItemRarity Rarity { get; set; } = Rarity;
    }
}
