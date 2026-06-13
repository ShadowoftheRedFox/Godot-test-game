using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata;
using Godot;
using Items;
using Utils;

namespace Inventory
{
    public abstract partial class AbstractInventory
        : GodotObject,
            IFlatIndex,
            IEquatable<AbstractInventory>
    {
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
            get;
            set =>
                field = value.X * value.Y >= 0 is true
                    ? value
                    : throw new ArgumentException("Size cannot be negative", nameof(Size));
        } = new(5, 2);

        [Export]
        public int MaxItemPerSlot { get; set; } = 100;

        public List<(AbstractItem item, int amount)> Items = [];

        /// <summary>
        /// True if the player can remove items from the inventory.
        /// </summary>
        [Export]
        public bool player_can_remove = true;

        /// <summary>
        /// True if the player can add items to the inventory.
        /// </summary>
        [Export]
        public bool player_can_add = true;

        /// <summary>
        /// Create a new abstract inventory, with basic IO functions.
        /// </summary>
        /// <param name="Size">The size of the inventory.</param>
        /// <param name="MaxItemPerSlot">The max number of items per slot.</param>
        /// <param name="player_can_add">If the player can add items into this.</param>
        /// <param name="player_can_remove">If the player can remove items into this.</param>
        /// <exception cref="ArgumentOutOfRangeException">If size X*Y is lesser or equal to 0, or max items per slot is lesser or equal to 0.</exception>
        public AbstractInventory(
            Vector2I Size,
            int MaxItemPerSlot,
            bool player_can_add = true,
            bool player_can_remove = true
        )
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
            this.player_can_add = player_can_add;
            this.player_can_remove = player_can_remove;

            // we made sure it's positive when we set Size
            int totalSize = this.Size.Y * this.Size.X;
            // resize our list to accept future items
            Items.EnsureCapacity(totalSize);
            // fill it with empty values
            for (int i = 0; i < totalSize; i++)
            {
                Items[i] = (null, 0);
            }
        }

        /// <summary>
        /// Add the given amount of item in the first slot available.
        /// </summary>
        /// <param name="Item">The item to add.</param>
        /// <param name="Amount">The quantity of items to add.</param>
        /// <returns>The overflow, if all the items couldn't be added.</returns>
        public int AddItem(AbstractItem Item, int Amount)
        {
            return AddItem(Item, Amount, 0);
        }

        /// <summary>
        /// Add the given amount of item in the first available slot starting from Position.
        /// </summary>
        /// <param name="Item">The item to add.</param>
        /// <param name="Amount">The quantity of items to add.</param>
        /// <param name="Position">The position we want to start adding item into.</param>
        /// <returns>The overflow, if all the items couldn't be added.</returns>
        public int AddItem(AbstractItem Item, int Amount, Vector2I Position)
        {
            return AddItem(Item, Amount, GetIndex(Position));
        }

        /// <summary>
        /// Add the given amount of item in the first available slot starting from Position.
        /// </summary>
        /// <param name="Item">The item to add.</param>
        /// <param name="Amount">The quantity of items to add.</param>
        /// <param name="Position">The position we want to start adding item into.</param>
        /// <returns>The overflow, if all the items couldn't be added.</returns>
        public int AddItem(AbstractItem Item, int Amount, int Position)
        {
            if (Amount <= 0)
                return 0;
            if (!player_can_add || Item == null || Position < 0 || Size.X * Size.Y <= Position)
                return Amount;

            // we want to continue for all position AND until we have amount left to add
            for (int i = Position; i < Size.Y * Size.X && Amount > 0; i++)
            {
                var pair = Items[i];
                // not the same item or no space left
                if (pair.amount >= MaxItemPerSlot || pair.item != Item)
                    continue;

                int spaceLeft = MaxItemPerSlot - pair.amount;
                // fill that slot as much as possible with the rest of the amount
                if (spaceLeft >= Amount)
                {
                    pair.amount += Amount;
                }
                else
                {
                    // we have more amountLeft than spaceLeft
                    Amount -= spaceLeft;
                    pair.amount = MaxItemPerSlot;
                }
                // we can do this because we check if amount left is not zero in the loop condition
                Items[i] = pair;
                EmitSignal(SignalName.ItemsUpdated, GetVectorIndex(i));
            }

            return Amount;
        }

        /// <summary>
        /// Remove the given amount of item from the given slot. This remove only at the slot position given. Any excess will be returned as underflow.
        /// If the parameter aren't valid, null is returned instead of an item.
        /// </summary>
        /// <param name="Amount">The quantity of items to remove.</param>
        /// <param name="Position">The position we want to start to remove item from.</param>
        /// <returns>The underflow, if all threre was more items to remove than available, and the item removed at that position.</returns>
        public (int amount, AbstractItem item) RemoveItem(int Amount, Vector2I Position)
        {
            return RemoveItem(Amount, GetIndex(Position));
        }

        /// <summary>
        /// Remove the given amount of item from the given slot.
        /// If the parameter aren't valid, null is returned instead of an item.
        /// </summary>
        /// <param name="Amount">The quantity of items to remove.</param>
        /// <param name="Position">The position we want to start to remove item from.</param>
        /// <returns>The underflow, if all threre was more items to remove than available, and the item removed at that position.</returns>
        public (int remaining, AbstractItem item) RemoveItem(int Amount, int Position)
        {
            if (Amount <= 0)
                return (0, null);
            if (!player_can_remove || Position < 0 || Size.X * Size.Y <= Position)
                return (Amount, null);

            var item = Items[Position].item;

            // if amount if greater than max item, we will have leftover
            int leftOver = 0;
            if (Amount > MaxItemPerSlot)
            {
                leftOver = Amount - MaxItemPerSlot;
                Amount = MaxItemPerSlot;
            }

            return (RemoveItem(item, Amount, Position) + leftOver, item);
        }

        /// <summary>
        /// Remove the given amount of item from the first available slot.
        /// </summary>
        /// <param name="Item">The item to remove.</param>
        /// <param name="Amount">The quantity of items to remove.</param>
        /// <param name="Position">Optionnal. The starting index to look at.</param>
        /// <returns>The underflow, if all threre was more items to remove than available.</returns>
        public int RemoveItem(AbstractItem Item, int Amount, Vector2I? Position)
        {
            return RemoveItem(Item, Amount, Position == null ? 0 : GetIndex((Vector2I)Position));
        }

        /// <summary>
        /// Remove the given amount of item from the first available slot.
        /// </summary>
        /// <param name="Item">The item to remove.</param>
        /// <param name="Amount">The quantity of items to remove.</param>
        /// <param name="Position">Optionnal. The starting index to look at.</param>
        /// <returns>The underflow, if all threre was more items to remove than available.</returns>
        public int RemoveItem(AbstractItem Item, int Amount, int Position = 0)
        {
            if (Amount <= 0)
                return 0;
            if (Item == null || Position < 0 || Size.X * Size.Y <= Position)
                return Amount;

            for (int i = Position; i < Size.Y * Size.X && Amount > 0; i++)
            {
                var pair = Items[i];
                // not the same item or no item
                if (pair.item != Item || pair.amount == 0)
                    continue;

                // we can empty amount
                if (pair.amount >= Amount)
                {
                    pair.amount -= Amount;
                    Amount = 0;
                    pair.item = null;
                }
                else
                {
                    // we have more amount than the pair
                    Amount -= pair.amount;
                    pair.amount = 0;
                }
                // we can do this because we check if amount left is not zero in the loop condition
                Items[i] = pair;
                EmitSignal(SignalName.ItemsUpdated, GetVectorIndex(i));
            }

            return Amount;
        }

        /// <summary>
        /// Move the item from the source slot to the destination slot.
        /// </summary>
        /// <param name="Source">The source slot position.</param>
        /// <param name="Destination">The destination slot position.</param>
        /// <returns>The amount of items moved.</returns>
        public int MoveOwnItem(Vector2I Source, Vector2I Destination)
        {
            return MoveOwnItem(GetIndex(Source), GetIndex(Destination));
        }

        /// <summary>
        /// Move the item from the source slot to the destination slot in the same inventory.
        /// </summary>
        /// <param name="Source">The source slot position.</param>
        /// <param name="Destination">The destination slot position.</param>
        /// <returns>The amount of items moved.</returns>
        public int MoveOwnItem(int Source, int Destination)
        {
            return MoveItem(Source, this, Destination);
        }

        /// <summary>
        /// Move the item from the source slot of this inventory, to the destination slot in the destination inventory.
        /// </summary>
        /// <param name="Source">The source slot position.</param>
        /// <param name="OtherDestination">The destination inventory.</param>
        /// <param name="Destination">The destination slot position.</param>
        /// <returns>The amount of items moved.</returns>
        public int MoveItem(int Source, AbstractInventory OtherDestination, int Destination)
        {
            if (
                OtherDestination == null
                || Source < 0
                || Destination < 0
                || Size.X * Size.Y <= Source
                || OtherDestination.Size.X * OtherDestination.Size.Y <= Destination
            )
                return 0;

            var (itemSource, amountSource) = Items[Source];
            var (itemDestination, amountDestination) = OtherDestination.Items[Destination];

            // both are empty
            if (amountSource == 0 && amountDestination == 0)
                return 0;

            int amountMoved;

            // same pair, add to destination
            if (itemSource == itemDestination)
            {
                int spaceLeft = OtherDestination.MaxItemPerSlot - amountDestination;
                if (amountSource <= spaceLeft) // anough to empty the source
                {
                    amountDestination += amountSource;
                    amountMoved = amountSource;
                    amountSource = 0;
                    itemSource = null;
                }
                else // more source amount than available on destination
                {
                    amountDestination += spaceLeft;
                    amountMoved = spaceLeft;
                    amountSource -= spaceLeft;
                }

                // update amounts
                Items[Source] = (itemSource, amountSource);
                OtherDestination.Items[Destination] = (itemDestination, amountDestination);
            }
            else
            {
                // swap pairs
                (OtherDestination.Items[Destination], Items[Source]) = (
                    Items[Source],
                    OtherDestination.Items[Destination]
                );

                amountMoved = Math.Max(amountSource, amountDestination);
            }

            // update items
            EmitSignal(SignalName.ItemsUpdated, GetVectorIndex(Source));
            OtherDestination.EmitSignal(
                SignalName.ItemsUpdated,
                OtherDestination.GetVectorIndex(Destination)
            );

            return amountMoved;
        }

        /// <summary>
        /// Get the amount of the given item in the inventory.
        /// </summary>
        /// <param name="Item">The item to get the amount of.</param>
        /// <returns>The amount of item in this inventory.</returns>
        public int GetItemAmount(AbstractItem Item)
        {
            if (Item == null)
                return 0;
            int res = 0;
            Items.ForEach(pair =>
            {
                if (pair.item == Item)
                    res += pair.amount;
            });
            return res;
        }

        public int GetIndex(Vector2I Vector)
        {
            if (Vector.X * Vector.Y < 0)
                throw new ArgumentException("Vector area cannot be negative", nameof(Vector));
            return Vector.Y * Size.X + Vector.X;
        }

        public Vector2I GetVectorIndex(int Position)
        {
            if (Position < 0)
                throw new ArgumentException("Position cannot be negative", nameof(Position));
            return new Vector2I(Position % Size.X, Position / Size.X);
        }

        public override string ToString()
        {
            string text = "AbstractInventory" + Size.ToString() + "[";
            int i = 1;
            Items.ForEach(
                (item) =>
                {
                    text += item.ToString();
                    if (i++ < Size.X * Size.Y)
                        text += ",";
                }
            );
            return text + "]";
        }

        public override bool Equals(object obj)
        {
            if (obj is AbstractInventory other)
                return Equals(other);
            return false;
        }

        /// <summary>
        /// Check if other is equal to this inventory, without checking the contents.
        /// </summary>
        /// <param name="other">The other inventory.</param>
        /// <returns>True if both inventory shares the same property values, except items.</returns>
        public bool Equals(AbstractInventory other)
        {
            if (other == null)
                return false;

            if (
                Size != other.Size
                || MaxItemPerSlot != other.MaxItemPerSlot
                || player_can_add != other.player_can_add
                || player_can_remove != other.player_can_remove
            )
                return false;

            for (int i = 0; i < Size.X * Size.Y; i++)
            {
                if (Items[i] != other.Items[i])
                    return false;
            }

            return true;
        }

        public abstract override int GetHashCode();
    }
}
