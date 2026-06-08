using System;
using Godot;

namespace Inventory
{
    public partial class PlayerInventory(Vector2I Size, int MaxItemPerSlot)
        : AbstractInventory(Size, MaxItemPerSlot, true, true)
    {
        public override int GetHashCode()
        {
            return HashCode.Combine(Size, MaxItemPerSlot);
        }
    }
}
