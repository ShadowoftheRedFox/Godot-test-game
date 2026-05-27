using System;
using System.Collections.Generic;
using System.Linq;
using Godot;
using Items;
using Utils;

namespace Inventory
{
    public abstract partial class AbstractInventory : GodotObject, IFlatIndex
    {
        [Signal]
        public delegate void AddSlotEventHandler(Slot Slot);

        /// <summary>
        /// Fires when an item has been updated inside the inventory.
        /// </summary>
        /// <param name="Position">
        /// The slot position updated.
        /// If values are (-1,X), then all slots of the column X have been updated.
        /// If values are (Y,-1), then all slots of the row Y have been updated.
        /// If values are (-1,-1), then all slots have been updated.
        /// </param>
        [Signal]
        public delegate void ItemsUpdatedEventHandler(Vector2I Position);


        [Export]
        public Vector2I Size
        {
            get; set => field = value.X * value.Y >= 0 is true
                 ? value
                 : throw new ArgumentException("Size cannot be negative", nameof(Size));
        } = new(5, 2);

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

            // we made sure it's positive when we set Size
            int totalSize = this.Size.Y * this.Size.X;
            // TODO need to do cpacity = EnsureCapacity or it does it internally?
            // resize out list to accept future slots
            Slots.EnsureCapacity(totalSize);
            // same for items
            Items.EnsureCapacity(totalSize);

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
                    delegate (Slot a, Slot b)
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
        /// Add the given amount of item in the first slot available.
        /// </summary>
        /// <param name="Item">The item to add.</param>
        /// <param name="Amount">The quantity of items to add.</param>
        /// <returns>The overflow, if all the items couldn't be added.</returns>
        public uint AddItem(AbstractItem Item, uint Amount)
        {
            return this.AddItem(Item, Amount, 0);
        }

        /// <summary>
        /// Add the given amount of item in the first available slot starting from Position.
        /// </summary>
        /// <param name="Item">The item to add.</param>
        /// <param name="Amount">The quantity of items to add.</param>
        /// <param name="Position">The position we want to start adding item into.</param>
        /// <returns>The overflow, if all the items couldn't be added.</returns>
        public uint AddItem(AbstractItem Item, uint Amount, Vector2I Position)
        {
            return this.AddItem(Item, Amount, GetIndex(Position));
        }

        /// <summary>
        /// Add the given amount of item in the first available slot starting from Position.
        /// </summary>
        /// <param name="Item">The item to add.</param>
        /// <param name="Amount">The quantity of items to add.</param>
        /// <param name="Position">The position we want to start adding item into.</param>
        /// <returns>The overflow, if all the items couldn't be added.</returns>
        public uint AddItem(AbstractItem Item, uint Amount, uint Position)
        {
            if (Item == null) return Amount;

            uint amountLeft = Amount;

            // we want to continue for all position AND until we have amount left to add
            for (int i = (int)Position; i < this.Size.Y * this.Size.X && amountLeft > 0; i++)
            {
                var pair = Items[i]; // FIXME are C# elements of list are passed as reference or copy?
                // not the same item, skip
                if (!pair.Key.Equals(Item)) continue;
                // same item, check if we can add some more in that slot
                if (pair.Value < this.MaxItemPerSlot)
                {
                    // fill that slot as much as possible
                    uint spaceLeft = this.MaxItemPerSlot - pair.Value;
                    if (spaceLeft <= amountLeft)
                    {
                        Items[i].Value += amountLeft; //FIXME

                    }
                }
            }
            // TODO finish
            return amountLeft;
        }

        /// <summary>
        /// Remove the given amount of item from the first avilable slot.
        /// </summary>
        /// <param name="Item">The item to remove.</param>
        /// <param name="Amount">The quantity of items to remove.</param>
        /// <returns>The underflow, if all threre was more items to remove than available.</returns>
        public uint RemoveItem(AbstractItem Item, uint Amount)
        {
            return this.RemoveItem(Item, Amount, 0);
        }

        /// <summary>
        /// Remove the given amount of item from the first avilable slot.
        /// </summary>
        /// <param name="Item">The item to remove.</param>
        /// <param name="Amount">The quantity of items to remove.</param>
        /// <param name="Position">The position we want to start to remove item from.</param>
        /// <returns>The underflow, if all threre was more items to remove than available.</returns>
        public uint RemoveItem(AbstractItem Item, uint Amount, Vector2I Position)
        {
            return this.RemoveItem(Item, Amount, this.GetIndex(Position));
        }

        /// <summary>
        /// Remove the given amount of item from the first avilable slot.
        /// </summary>
        /// <param name="Item">The item to remove.</param>
        /// <param name="Amount">The quantity of items to remove.</param>
        /// <param name="Position">The position we want to start to remove item from.</param>
        /// <returns>The underflow, if all threre was more items to remove than available.</returns>
        public abstract uint RemoveItem(AbstractItem Item, uint Amount, uint Position);

        /// <summary>
        /// Remove the given amount of item from the first avilable slot.
        /// </summary>
        /// <param name="Item">The item to remove.</param>
        /// <param name="Amount">The quantity of items to remove.</param>
        /// <param name="Position">The position we want to start to remove item from.</param>
        /// <returns>The underflow, if all threre was more items to remove than available.</returns>
        public void MoveOwnItem(Vector2I Source, Vector2I Destination)
        {
            this.MoveOwnItem(this.GetIndex(Source), this.GetIndex(Destination));
        }
        public abstract void MoveOwnItem(uint Source, uint Destination);

        public uint GetIndex(Vector2I Vector)
        {
            if (Vector.X * Vector.Y < 0) throw new ArgumentException("Vector area cannot be negative", nameof(Vector));
            return (uint)(Vector.Y * this.Size.X + Vector.X);
        }

        public override string ToString()
        {
            // TODO
            return base.ToString();
        }
        public override bool Equals(object obj)
        {
            // TODO
            return base.Equals(obj);
        }

        public override int GetHashCode()
        {
            // TODO
            return base.GetHashCode();
        }
    }

    public partial class Slot(AbstractInventory inventory, Vector2I positionOrder) : Node2D
    {
        /// <summary>
        /// The inventory that owns this slot.
        /// </summary>
        public AbstractInventory Inventory = inventory ?? throw new ArgumentNullException(nameof(inventory), "Owner's inventory cannot be null");

        /// <summary>
        /// The position of the slot in the inventory in 2D.
        /// </summary>
        public Vector2I PositionOrder
        {
            get; set => field = value.X * value.Y >= 0 is true
                 ? value
                 : throw new ArgumentException("Position in inventory cannot be negative", nameof(PositionOrder));
        } = positionOrder;
    }
}
