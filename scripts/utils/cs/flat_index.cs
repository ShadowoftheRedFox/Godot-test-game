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
        public int GetIndex(Vector2I Vector);

        /// <summary>
        /// Get the vector index from a flat index.
        /// </summary>
        /// <param name="position">The flat index.</param>
        /// <returns>The vectored index.</returns>
        /// <exception cref="ArgumentException">If the position is negative.</exception>
        public Vector2I GetVectorIndex(int position);
    }
}
