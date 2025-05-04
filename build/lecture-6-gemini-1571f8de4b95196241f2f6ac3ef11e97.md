## Chapter 6: Snipping Away the Unseen - The Art of Clipping

Welcome, intrepid explorer of the digital canvas, to a crucial stage in our journey through the realm of computer graphics: **Clipping**. Up until now, we've conjured 3D scenes filled with objects, adorned them with materials and bathed them in light, and even positioned our virtual camera to frame the view. But what happens to the parts of our meticulously crafted world that fall outside the camera's gaze? Do we waste precious computational resources on them? The answer, thankfully, is no. This is where the elegant process of clipping steps in, acting as a discerning gatekeeper, ensuring that only what is visible makes its way further down the graphics pipeline.

### Defining the Boundaries: What is Clipping?

At its heart, **clipping** is the process of **determining which parts of a graphical object lie within the viewing region and discarding or modifying the parts that lie outside**. Think of it like taking a photograph through a window. The window frame defines the boundaries of your view; anything outside this frame is not captured in the image. In computer graphics, the "window" is typically the **viewing frustum** in 3D space, which gets projected onto a 2D **clip window** or **viewport** on the screen.

The primary goal of clipping is two-fold:

*   **Efficiency:** By removing invisible geometry early in the pipeline, we avoid performing unnecessary calculations for transformations, illumination (shading), and rasterisation on parts of the scene that will never be displayed. This significantly improves rendering performance.
*   **Visual Coherence:** Clipping ensures that only the relevant portions of objects are drawn, preventing artifacts and maintaining a visually consistent scene.

### Why Bother? The Necessity of Clipping

Imagine rendering a vast landscape. Without clipping, your graphics system would have to process every tree, every hill, even the distant mountains that are only a few pixels on the horizon (or completely obscured). This would be incredibly inefficient. Clipping allows us to focus our efforts on the geometry that actually contributes to the final image.

Consider a simple example: a line segment that extends far beyond the edges of your screen. Without clipping, the rasteriser (the process that converts 2D primitives into pixels) would attempt to draw pixels for the entire length of the line, most of which would be off-screen. Clipping neatly trims this line segment to the visible portion, saving computation and ensuring a clean image.

### The Clipping Arena: Normalised Device Coordinates (NDC)

Before we delve into specific clipping algorithms, it's important to understand where this process typically takes place in the graphics pipeline. As we learned in earlier chapters, after the **modelling transformations** (positioning objects in the world) and the **viewing transformation** (positioning the camera and orienting the scene relative to it), the 3D scene is projected into **Normalised Device Coordinates (NDC)**.

In NDC space, the viewing volume is typically a cube ranging from -1 to +1 in all three dimensions (x, y, and z). The near and far clipping planes of the view frustum are mapped to the z = -1 and z = +1 planes in NDC, respectively, and the image boundaries correspond to the x and y extents of this cube. **Clipping operations are most conveniently performed in this NDC space**, as the clip boundaries are well-defined and consistent.

### Families of Clipping Algorithms

The sources introduce several algorithms tailored for different types of geometric primitives:

*   **Point Clipping:** The simplest form of clipping, determining if a point lies within the defined 2D clip window.
*   **Line Segment Clipping:** Determining which portion (if any) of a line segment is visible within the clip window. Algorithms like **Cohen-Sutherland** and **Liang-Barsky** are discussed.
*   **Polygon Clipping:** Clipping the edges and potentially creating new vertices for polygons that intersect the clip window boundaries. The **Sutherland-Hodgeman** algorithm is mentioned.

Let's explore the intuition and mathematics behind some of these.

### Mathematical Intuition and Visual Examples

#### Point Clipping: A Simple Test

For a point *p(x, y)* to be inside a rectangular clip window defined by *xmin*, *xmax*, *ymin*, and *ymax*, it must satisfy the following simple inequalities:

```
xmin ≤ x ≤ xmax
ymin ≤ y ≤ ymax
```

**Visual Example:**

Imagine a rectangle representing our clip window. A point located anywhere within or on the boundary of this rectangle is considered visible. Any point outside these boundaries is clipped and not drawn.

#### Line Segment Clipping: Cohen-Sutherland - Divide and Conquer

The Cohen-Sutherland algorithm is an efficient approach for line segment clipping. It works by assigning a 4-bit **outcode** to each endpoint of the line segment. Each bit of the outcode corresponds to one of the four boundaries of the 2D clip window:

*   **Bit 1 (Left):** Set to 1 if the point is to the left of *xmin*.
*   **Bit 2 (Right):** Set to 1 if the point is to the right of *xmax*.
*   **Bit 3 (Bottom):** Set to 1 if the point is below *ymin*.
*   **Bit 4 (Top):** Set to 1 if the point is above *ymax*.

**Intuition:** By examining the outcodes of the two endpoints, we can quickly determine if the entire line segment is trivially accepted (both outcodes are 0000, meaning both endpoints are inside) or trivially rejected (the bitwise AND of the two outcodes is not 0000, meaning both endpoints lie on the same side of at least one of the clipping boundaries).

**Visual Example:**

```
        Top (bit 4)
          1001 | 1000 | 1010
         ------|------|------
Left (bit 1) 0001 | 0000 | 0010 Right (bit 2)
         ------|------|------
          0101 | 0100 | 0110
        Bottom (bit 3)
```

If a line segment has endpoints with outcodes 0000 and 0000 (e.g., P5 and P3 in), it's entirely inside and trivially accepted. If both endpoints have their "Left" bit set (e.g., a line above the "Top" boundary), their bitwise AND will also have the "Top" bit set, indicating trivial rejection.

If the line segment is neither trivially accepted nor rejected (the bitwise AND of the outcodes is 0000, but at least one outcode is not 0000), it means the line crosses one or more clipping boundaries. In this case, we need to find the intersection point(s) with the window edges. This can be done using the parametric equation of the line segment:

```
x(α) = x1 + α(x2 - x1)
y(α) = y1 + α(y2 - y1)
```

where *α* ranges from 0 to 1 for the segment between *(x1, y1)* and *(x2, y2)*. We can substitute the clip window boundaries (e.g., *x = xmin*) into this equation to solve for the parameter *α* at the intersection point. If *0 ≤ α ≤ 1*, the intersection point lies on the line segment. We then use this intersection point to replace the endpoint that lies outside the boundary and repeat the process until the entire segment is inside or trivially rejected.

#### Line Segment Clipping: Liang-Barsky - A Parametric Approach

The Liang-Barsky algorithm also leverages the parametric form of the line segment. It treats the clipping problem as finding the range of the parameter *α* for which the line segment lies within the clip window. For each of the four clip boundaries, we can derive constraints on *α*. For example, for the left boundary *x = xmin*:

If *x2 - x1 < 0* (line goes from right to left), then *α > (xmin - x1) / (x2 - x1)*.
If *x2 - x1 > 0* (line goes from left to right), then *α < (xmin - x1) / (x2 - x1)*.

Similar inequalities can be derived for the right, bottom, and top boundaries. By finding the intersection of these parameter ranges, we can determine the portion of the line segment that is inside the clip window. If the resulting valid range for *α* is empty, the line segment is entirely outside.

#### Polygon Clipping: Sutherland-Hodgeman - Clip Against Each Edge

The Sutherland-Hodgeman algorithm clips a polygon against each edge of the clip window sequentially. It processes the polygon's vertices one by one and determines whether to keep the vertex and/or introduce new vertices at the intersections with the clipping edge.

For each clipping edge, the algorithm considers four cases for consecutive vertices of the polygon:

1.  **Both vertices inside:** Keep the second vertex.
2.  **First vertex inside, second outside:** Keep the intersection point.
3.  **First vertex outside, second inside:** Keep the intersection point and the second vertex.
4.  **Both vertices outside:** Keep nothing.

After processing all vertices against one clipping edge, the resulting list of vertices forms a new, partially clipped polygon. This process is repeated for the remaining three edges of the clip window.

**Visual Example:**

Imagine a triangle being clipped by the left edge of the clip window. If the first vertex is inside and the second is outside, we calculate the intersection point and add it to our new polygon. If the next vertex is also outside, we add nothing. If the following vertex is inside, we calculate the intersection and add it, followed by the inside vertex itself. After processing all edges (left, right, bottom, top), we obtain the final clipped polygon.

### Clipping in 3D

The concepts of 2D clipping extend to 3D, where the clip volume is defined by the view frustum. Algorithms like Cohen-Sutherland can be adapted for 3D by using a 6-bit outcode (for the six clipping planes: left, right, top, bottom, near, and far). However, the fundamental principle of discarding geometry outside the viewing volume remains the same. Before projecting the 3D scene to 2D, clipping in 3D ensures that only the geometry within the camera's view is processed further. The near and far clipping planes are crucial in 3D clipping, defining the depth range of visibility. Primitives with vertices both in front and behind the eye necessitate clipping against these planes.

### The Importance Revisited

Clipping is not merely a technical detail; it's a cornerstone of efficient and visually correct rendering. By strategically removing unseen portions of our 3D world, we pave the way for faster frame rates and a more seamless experience for the viewer. It’s a testament to the power of careful geometric processing in creating the illusions we see on our screens.

### Clipping in the Grand Scheme

As we've seen, clipping sits squarely within the **graphics pipeline**. It comes after the **transformation stages** (modelling and viewing) that position and orient our scene, and before **rasterisation** turns our geometric primitives into pixels. The clipped primitives are then ready for the next crucial steps: determining visibility (which surfaces are in front of others) and finally, rendering the visible portions with the appropriate colours and shading. Understanding clipping is thus essential to grasping the entire flow of how a 3D scene is transformed into the 2D images we perceive.

In our continuing exploration, we will see how the clipped geometry is then processed to determine which pixels on the screen should be coloured and with what intensity. Clipping, in its silent efficiency, sets the stage for the visual magic that follows.
