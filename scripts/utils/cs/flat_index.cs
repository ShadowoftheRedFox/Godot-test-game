using Godot;

namespace Utils
{
    public interface IFlatIndex
    {
        /// <summary>
        /// Get the flat index from a vector index.
        /// </summary>
        /// <param name="Vector">The index vector.</param>
        /// <returns>The flattened index.</returns>
        /// <exception cref="ArgumentException">If the vector area (X*Y) is negative.</exception>
        public uint GetIndex(Vector2I Vector);
    }
}
