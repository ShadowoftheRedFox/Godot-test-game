using System;
using System.Collections.Generic;
using System.Linq;
using Godot;
using Items;

namespace Inventory
{
    public abstract partial class AbstractInventory : GodotObject
    {
        [Signal]
        public delegate void AddSlotEventHandler(Slot Slot);

        [Export]
        public Vector2I Size { get; set; } = new(5, 2);

        [Export]
        public uint MaxItemPerSlot { get; set; } = 100;

        public List<KeyValuePair<AbstractItem, uint>> Items = [];

        protected List<Slot> Slots = [];

        public AbstractInventory(Vector2I Size, uint MaxItemPerSlot)
        {
            if (Size.X * Size.Y <= 0)
                throw new ArgumentOutOfRangeException(
                    nameof(Size),
                    "Size cannot be negative or zero"
                );
            if (MaxItemPerSlot <= 0)
                throw new ArgumentOutOfRangeException(
                    nameof(MaxItemPerSlot),
                    "The max number of items per slot cannot be negative or zero"
                );
            this.Size = Size;
            this.MaxItemPerSlot = MaxItemPerSlot;

            // resize out list to accept future slots
            Slots.Capacity = Size.X * Size.Y;

            AddSlot += OnSlotAdded;
        }

        private void OnSlotAdded(Slot Slot)
        {
            Slots.Add(Slot);

            // when all the slots are here, sort them, so we can access the
            // correct one using a flattened index
            if (Slots.Count == Size.X * Size.Y)
            {
                Slots.Sort(
                    delegate(Slot a, Slot b)
                    {
                        return a.PositionOrder.Y * Size.X
                            + a.PositionOrder.X
                            - b.PositionOrder.Y * Size.X
                            + b.PositionOrder.X;
                    }
                );
            }
        }

        /// <summary>
        /// Add the given item in the first slot available.
        /// </summary>
        /// <param name="Item">The item to add.</param>
        /// <param name="Amount">The quantity to add.</param>
        /// <returns>The overflow, if all the items couldn't be added.</returns>
        public abstract uint AddItem(AbstractItem Item, uint Amount);
        public abstract uint AddItem(AbstractItem Item, uint Amount, Vector2I position);
        public abstract uint AddItem(AbstractItem Item, uint Amount, uint position);
        public abstract uint RemoveItem(AbstractItem Item, uint Amount);
        public abstract uint RemoveItem(AbstractItem Item, uint Amount, Vector2I position);
        public abstract uint RemoveItem(AbstractItem Item, uint Amount, uint position);
        public abstract void MoveOwnItem(Vector2I source, Vector2I end);
        public abstract void MoveOwnItem(uint source, uint end);
    }

    public partial class Slot : Node2D
    {
        public Vector2I PositionOrder { get; set; } = Vector2I.Zero;
    }
}
