## Chapter 7: Eliminating the Unseen and Painting the Surfaces

This chapter delves into two critical stages of the graphics pipeline, often grouped together due to their close relationship in the final rendering process: **Élimination des Parties Cachées (Hidden Surface Removal)** and **Remplissage (Polygon Filling)**. Following the transformations, illumination, and clipping stages discussed in previous lectures, these steps are crucial for generating the final, viewable image from a 3D scene. Hidden surface removal addresses the fundamental problem of visibility – determining which parts of the 3D objects are visible to the virtual camera and which are obscured by others. Once the visible surfaces are identified, polygon filling techniques come into play to render the interiors of these projected 2D polygons, providing a more realistic appearance to the objects.

### The Challenge of Visibility: Hidden Surface Removal

In a 3D scene, objects are positioned at varying depths relative to the camera. When these objects are projected onto a 2D image plane, some surfaces will inevitably be occluded by others that are closer to the viewpoint. The process of **hidden surface removal** aims to identify and discard these occluded portions, ensuring that only the visible parts of the scene are rendered. Several algorithms have been developed to tackle this problem, each with its own trade-offs in terms of computational cost, memory usage, and suitability for different types of scenes. These algorithms can be broadly categorised into **object-space** and **image-space** approaches.

#### Object-Space Algorithms

Object-space algorithms primarily work with the 3D geometry of the scene to determine visibility before projection or rasterisation.

*   **Backface Culling:** This is a relatively simple yet effective preliminary step. It leverages the fact that for closed, solid objects, faces whose normals point away from the viewer are generally not visible. By calculating the dot product of the surface normal and the vector to the viewpoint, faces with a positive or zero dot product (depending on convention) can be discarded. This technique can save approximately 50% of the processing time on average and has a low cost per polygon. However, it is only sufficient for single, convex objects.

*   **Painter's Algorithm:** Also known as the "depth-sort algorithm", this method aims to render polygons in order of decreasing depth from the viewer. The idea is analogous to how a painter layers paint, with closer objects painted last, obscuring those behind them. The algorithm first sorts all the polygons in the scene based on their farthest z-coordinate (depth). It then draws the polygons starting from the farthest to the nearest. While conceptually simple, the Painter's Algorithm faces challenges with overlapping polygons where a simple depth sort is insufficient to determine the correct visibility order. In such ambiguous cases, polygon splitting might be necessary.

*   **BSP Trees (Binary Space Partition Trees):** This approach involves recursively subdividing the 3D space containing the scene's primitives using a series of splitting planes. The result is a hierarchical tree structure (a Directed Acyclic Graph - DAG) that efficiently organises the scene. To render the scene, the BSP tree is traversed recursively. For each node, the position of the viewpoint relative to the splitting plane is determined. The subtree on the far side of the plane (relative to the viewer) is rendered first, then the primitive associated with the current node (if any), and finally the subtree on the near side. This traversal order ensures that objects are drawn back-to-front, effectively resolving visibility in many cases. However, constructing the BSP tree can be computationally intensive, and splitting primitives can increase the complexity of the scene.

#### Image-Space Algorithms

Image-space algorithms determine visibility after the scene has been projected onto the 2D image plane.

*   **Warnock Subdivision Algorithm:** This algorithm employs a "divide and conquer" strategy by recursively subdividing the image plane into smaller quadrants (a quadtree). For each quadrant, it determines the list of potentially visible polygons. In simple cases, such as when a quadrant contains no polygons or only a single polygon that entirely covers it, the rendering is straightforward. However, when a quadrant contains multiple overlapping polygons, the algorithm attempts to determine if one polygon obscures all others within that region based on depth. If a clear frontmost polygon cannot be identified, the quadrant is further subdivided, and the process is repeated. The subdivision continues until each quadrant is smaller than a pixel, at which point the colour of the closest polygon is assigned.

*   **Scan-Line Algorithms:** These algorithms process the image row by row (scan line by scan line) to determine visibility. For each scan line, the algorithm identifies the intersections of the scan line with the edges of the projected polygons. These intersections divide the scan line into intervals. The visibility of the polygons within each interval is then determined by comparing their depths (z-values) at that particular scan line. Algorithms like **Scan-Line-Watkins** and **Scan-Line-Z-buffer** utilise this principle. The Scan-Line-Z-buffer method maintains a depth buffer (z-buffer) for the current scan line, storing the depth of the closest fragment encountered so far for each pixel along the line.

*   **Z-buffer Algorithm (Depth Buffer):** The **Z-buffer algorithm**, introduced by Edwin Catmull, is one of the most widely used hidden surface removal techniques, particularly in hardware-accelerated graphics. It operates on a pixel-by-pixel basis and requires two buffers: a **frame buffer** to store the colour of each pixel and a **z-buffer (depth buffer)** to store the depth (z-value) of the object visible at each pixel. Initially, the z-buffer is filled with a value representing infinite depth, and the frame buffer is set to the background colour. As each polygon is rasterised (converted into fragments or pixels), the depth of the generated fragment is calculated. This depth is then compared to the value currently stored in the z-buffer at the corresponding pixel location. If the fragment's depth is less than the stored depth (meaning it is closer to the viewer), the z-buffer is updated with the new depth, and the frame buffer is updated with the fragment's colour. After processing all polygons, the frame buffer contains the final image with hidden surfaces correctly removed. The Z-buffer algorithm is relatively simple to implement, doesn't require pre-sorting, and is highly parallelisable. However, it processes all polygons, even those that are entirely hidden, and has memory overhead for the z-buffer. It also doesn't inherently handle transparency or inter-reflections correctly.

#### Choosing a Hidden Surface Removal Algorithm

The choice of a particular hidden surface removal algorithm depends on various factors, including the complexity of the scene, the available hardware, and any specific rendering requirements beyond basic visibility. The Z-buffer algorithm is commonly provided by graphics libraries and hardware due to its simplicity and efficiency in many scenarios. Scan-line algorithms can be efficient when memory is limited or when specific rendering effects are desired that might be more easily integrated into the scan-line processing.

### Filling the Polygons: Rendering the Interiors

Once the visible polygons (or parts thereof after clipping) have been determined, the next step is to **fill their interiors** with the appropriate colours and attributes. This process, known as **polygon filling** or **rasterisation**, converts the 2D outline of the projected polygon into a set of discrete pixels on the screen and assigns them the calculated colours, often based on the illumination and shading models discussed previously.

A common approach to polygon filling is the **scan-line fill algorithm**. For each scan line that intersects the polygon, the algorithm determines the segments of the scan line that lie within the polygon's boundaries. This typically involves finding the intersection points of the scan line with the polygon edges, sorting these intersection points along the x-axis, and then filling the pixels between pairs of consecutive intersection points. A **parity rule** is often used to determine whether a point lies inside or outside the polygon. As the scan line moves across the polygon, the colour of the pixels being filled is determined by interpolating the colour or intensity values across the polygon, potentially using techniques like Gouraud or Phong shading.

Another category of filling algorithms includes **seed fill** or **flood fill** algorithms. These algorithms start from an initial pixel known to be inside the polygon (the "seed") and recursively or iteratively fill adjacent pixels that belong to the polygon's interior based on a boundary condition (e.g., reaching an edge of a different colour or a predefined boundary).

Handling **boundary conflicts** is an important consideration in polygon filling. Due to the discrete nature of pixels and potential approximations in edge tracing, intersection points might not fall exactly on pixel centres. Robust filling algorithms often implement rules to ensure that adjacent polygons sharing an edge do not leave gaps or overlap in the final rendered image.

Expanding on:
**Filling the Polygons: Rasterisation**

The terms "Filling the Polygons" and **rasterisation** essentially describe the process of converting the 2D projected primitives, which are often broken down into **triangles**, into a set of discrete pixels on the screen and assigning them colours. The goal is to render the interiors of these polygons, providing a more realistic and continuous appearance to the objects. The rasterisation pipeline takes 3D primitives as input and produces a bitmap image as output.

**Why Triangles?**

The sources highlight why triangles are the fundamental primitive for rasterisation:

*   They can approximate any shape.
*   They are always planar with a well-defined normal vector.
*   It is easy to interpolate data across a triangle.

Even points and lines are conceptually converted into triangles within the rasterisation pipeline.

**The Process of Rasterisation**

Rasterisation involves determining which pixels on the screen are covered by the projected 2D primitive (typically a triangle). For each pixel covered, the rasteriser also **interpolates** values known at the vertices of the primitive, such as colour and depth, to determine the corresponding values for that pixel (which is often referred to as a fragment).

**Polygon Filling Algorithms**

The sources discuss several methods for filling the projected polygons:

*   **Testing Point Membership:** This involves determining if a given point lies inside a polygon. Different approaches exist for convex and concave polygons.
    *   **Convex Polygons:** One method involves determining "exterior" normals and checking if the point lies on the correct side of all the edges (defined by the normals). Another test involves checking the sign of the cross product of consecutive edge vectors; for a convex polygon, the sign should remain consistent during traversal.
    *   **Concave Polygons:** Concave polygons can change their traversal direction.
    *   **Ray Casting (Number of Intersections Test):** This involves drawing a ray from the point and counting the number of times it intersects the edges of the polygon. An odd number of intersections generally indicates the point is inside, while an even number indicates it's outside. Care must be taken with edge cases like intersections at vertices or tangent edges.

*   **Intersection Tests:** These algorithms determine which parts of the screen are covered by the polygon by finding intersections with scan lines or other geometric entities.

*   **Scan-Line Algorithms:** These algorithms process the image line by line (horizontally) within the bounding box of the polygon.
    *   For each scan line, the algorithm finds the intersections between the scan line and the edges of the polygon. This can be done by approximating the segments using a line tracing algorithm.
    *   The intersection points are collected and organised, often in a linked list, and sorted by their x-coordinates.
    *   A **parity rule** is then applied: as the scan line traverses the polygon, a parity counter is incremented each time an edge is crossed. Pixels are filled if the parity is odd, indicating they are inside the polygon.
    *   To avoid gaps or overlaps along shared edges between polygons, algorithms need to handle boundary conflicts, often by considering points strictly inside the polygon.
    *   For each involved side of the polygon and each processed scan line (`yi`), the calculation of the intersection requires the `ymax`, `xmin`, and the inverse of the slope (`dx/dy`) of the edge.

*   **Region Filling (Seed Fill or Flood Fill):** These algorithms operate on regions defined by a boundary. Starting from an interior "seed" pixel, the filling colour is recursively or iteratively propagated to neighbouring pixels until the boundary of the region is reached.

**Integration with Shading**

The way polygons are filled is closely linked to the **shading model** being used. The shading model determines the colour of each pixel within the polygon. For example:

*   **Flat Shading (Lambert Shading):** A single illumination value is calculated for the entire polygon, often at the midpoint, using the face normal.
*   **Gouraud Shading:** Illumination intensities are calculated at the vertices of the polygon and then bilinearly interpolated across the face. This helps to eliminate intensity discontinuities. The interpolation can be done edge by edge and then horizontally across the span. Gouraud shading is efficient and commonly implemented in graphics hardware.
*   **Phong Shading:** Instead of interpolating intensities, Phong shading interpolates the surface normals at the vertices across the face. The illumination model is then applied at each pixel using the interpolated normal, resulting in more accurate specular highlights. This generally produces better results than Gouraud shading, especially for specular reflections, but is computationally more expensive.

The interpolation process during rasterisation often uses techniques like **linear interpolation** and **barycentric coordinates**. Barycentric coordinates can be used to interpolate any vertex attribute (colour, texture coordinates, etc.) across the triangle during rasterisation by measuring the "distance" to each edge or by using the ratio of triangle areas. For perspective projections, a perspective-correct interpolation method is needed.

**Graphics Pipeline Integration**

Polygon filling (rasterisation) is a crucial step in the graphics pipeline. The 2D projected and clipped primitives are fed into the rasteriser. The output is a set of pixel fragments with interpolated attributes like colour and depth, which are then passed on to the visibility determination stage (e.g., using a Z-buffer) and eventually written to the frame buffer.

In summary, "Filling the Polygons" or rasterisation is the process of converting 2D geometric primitives into pixels on the screen, using various algorithms to determine which pixels are inside the polygon and interpolating attributes across its surface, influenced by the chosen shading model, to create the final rendered image.

### Integration with the Graphics Pipeline

Hidden surface removal and polygon filling are tightly integrated within the graphics pipeline. Following the projection and clipping stages, the 2D projected primitives are passed to the rasterisation stage, where polygon filling occurs. If a Z-buffer is employed, it works in conjunction with the rasterisation process. As each fragment of a polygon is generated during rasterisation, its depth is checked against the Z-buffer to determine visibility before its colour is written to the frame buffer. The output of these stages is the final 2D image, ready to be displayed.

### Conclusion

Lecture 7, covering hidden surface removal and polygon filling, addresses fundamental challenges in rendering realistic 3D graphics. By correctly determining which surfaces are visible and accurately filling the interiors of the projected polygons, these techniques are essential for creating the final image that represents the 3D scene from the camera's perspective. The choice of algorithms for these stages significantly impacts the performance and visual quality of the rendered output, and a thorough understanding of these concepts is crucial for anyone working in the field of Informatique Graphique pour la Science des Données.
