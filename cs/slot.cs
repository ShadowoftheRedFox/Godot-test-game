using System;
using Godot;
using Items;

namespace Inventory
{
    public abstract partial class InventorySlot : Node
    {
        /// <summary>
        ///The inventory owning this slot.
        /// </summary>
        private AbstractInventory Inventory = null;

        /// <summary>
        /// The position of this slot in the inventory.
        /// </summary>
        private Vector2I Position = Vector2I.Zero;

        /// <summary>
        /// Visual representation of this slot.
        /// </summary>
        [Export]
        private Panel Panel = null;

        /// <summary>
        /// Container of a subviewport to show the 3D items.
        /// </summary>
        [Export]
        private SubViewportContainer SubViewportContainer = null;

        /// <summary>
        /// Shows the 3D items.
        /// </summary>
        [Export]
        private SubViewport SubViewport = null;

        /// <summary>
        /// Display the items amount.
        /// </summary>
        [Export]
        private Label Label = null;

        /// <summary>
        /// Create a new inventory slot, used to disply the content of the inventory for the item at the same given position.
        /// </summary>
        /// <param name="Inventory">The inventory to display.</param>
        /// <param name="Position">The item position in the inventory.</param>
        /// <exception cref="ArgumentOutOfRangeException">If position X*Y is less than 0.</exception>
        /// <exception cref="ArgumentNullException">If inventory is null.</exception>
        public InventorySlot(AbstractInventory Inventory, Vector2I Position)
        {
            if (Position.X * Position.Y < 0)
                throw new ArgumentOutOfRangeException(
                    nameof(Position),
                    "Position cannot be negative"
                );

            this.Inventory =
                Inventory
                ?? throw new ArgumentNullException(nameof(Inventory), "Inventory can't be null");
            this.Position = Position;

            // setup the visuals
            SetupVisuals();

            // setup listeners
            Inventory.ItemsUpdated += OnItemUpdate;
            Panel.MouseEntered += OnMouseEntered;
            Panel.MouseExited += OnMouseExited;
        }

        /// <summary>
        /// Prepare the visuals on initialisation.
        /// </summary>
        private void SetupVisuals()
        {
            StyleBoxFlat styleBox = new();
            styleBox.BgColor = new Color(0.1f, 0.1f, 0.1f, 0.6f);
            styleBox.SetContentMarginAll(5f);
            styleBox.SetCornerRadiusAll(10);

            Panel.AddThemeStyleboxOverride("panel", styleBox);
            // TODO check if another properties bound in the gd scene
            UpdateVisuals();
        }

        /// <summary>
        ///  Updates the visuals when items changes.
        /// </summary>
        private void UpdateVisuals()
        {
            const string NODE_NAME = "SV_INVENTORY_ITEM";
            var (item, amount) = Inventory.Items[(int)Inventory.GetIndex(Position)];

            if (item != null)
            {
                // add the item mesh to show it in the inventory
                MeshInstance3D meshInstance = new() { Mesh = item.GetMesh(), Name = NODE_NAME };
                SubViewport.AddChild(meshInstance);

                // show and update the panel
                Label.Text = amount.ToString();
                Panel.MouseDefaultCursorShape = Control.CursorShape.PointingHand;
                Panel.Theme.SetColor("font_color", "TooltipLabel", item.GetClassColor());
                Panel.TooltipText = item.Name;
                SubViewportContainer.Show();
            }
            else
            {
                // remove the mesh if there is
                var mesh = SubViewport.FindChild(NODE_NAME, false, true);
                if (mesh != null)
                {
                    mesh.QueueFree();
                }

                // hide and update the panel
                SubViewportContainer.Hide();
                Label.Text = "";
                Panel.MouseDefaultCursorShape = Control.CursorShape.CanDrop;
                Panel.Theme.SetColor("font_color", "TooltipLabel", new Color(1, 1, 1));
                Panel.TooltipText = "";
            }
        }

        private void OnMouseEntered()
        {
            OnHover(true);
        }

        private void OnMouseExited()
        {
            OnHover(false);
        }

        private void OnHover(bool Hover) { }

        /// <summary>
        /// Listens to the inventory for item changes on this position.
        /// </summary>
        /// <param name="Position">The position updated in the inventory.</param>
        private void OnItemUpdate(Vector2I Position)
        {
            if (this.Position != Position)
                return;
            UpdateVisuals();
        }
    }
}
