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

**Core Idea**

The Liang-Barsky algorithm is an efficient line clipping algorithm that leverages the *parametric* representation of a line segment.  Instead of directly computing intersection points, it determines the visible portion of the line by finding the range of the parameter *alpha (α)* that corresponds to the part of the line *inside* the clipping window.  The algorithm works with rectangular clipping windows, defined by `xmin`, `xmax`, `ymin`, and `ymax`.

**Parametric Equation of a Line Segment**

Any point `(x, y)` on a line segment between points `(x1, y1)` and `(x2, y2)` can be represented parametrically as:

*   `x = x1 + α(x2 - x1)`
*   `y = y1 + α(y2 - y1)`

where `0 ≤ α ≤ 1`.

*   `α = 0` corresponds to the point `(x1, y1)`.
*   `α = 1` corresponds to the point `(x2, y2)`.
*   Values of `α` between 0 and 1 represent points along the line segment between the endpoints.
*   Values of `α` outside the range [0, 1] represent points on the *infinite line* extending beyond the line segment.

**The Clipping Problem as a Range of α**

The Liang-Barsky algorithm's key insight is that the clipping problem can be transformed into finding the valid range of `α` for which the line segment lies within the clipping window.  That is, we want to find the values of `α` such that:

*   `xmin ≤ x ≤ xmax`
*   `ymin ≤ y ≤ ymax`

Substituting the parametric equations of the line segment into these inequalities gives us a way to constrain `α`.

**Deriving the Constraints on α**

Let's consider each clipping boundary (left, right, bottom, top) separately:

1.  **Left Boundary (x = xmin):**

    *   We need `xmin ≤ x = x1 + α(x2 - x1)`
    *   Rearranging, we get `xmin - x1 ≤ α(x2 - x1)`

    Now, we have two cases:

    *   **Case 1: (x2 - x1) < 0 (Line goes from right to left):**  Dividing by `(x2 - x1)` *reverses* the inequality sign:
        `α ≥ (xmin - x1) / (x2 - x1)`
    *   **Case 2: (x2 - x1) > 0 (Line goes from left to right):**  Dividing by `(x2 - x1)` *preserves* the inequality sign:
        `α ≤ (xmin - x1) / (x2 - x1)`
    *   **Case 3: (x2-x1) = 0: ** The line is vertical.
        *   If `x1 < xmin`, the line is totally on the left of the boundary and outside the window.
        *   If `x1 > xmin`, the line is totally on the right of the boundary and can be inside the window.

2.  **Right Boundary (x = xmax):**

    *   We need `x = x1 + α(x2 - x1) ≤ xmax`
    *   Rearranging, we get `α(x2 - x1) ≤ xmax - x1`

    Again, we have two cases:

    *   **Case 1: (x2 - x1) < 0 (Line goes from right to left):**
        `α ≤ (xmax - x1) / (x2 - x1)`
    *   **Case 2: (x2 - x1) > 0 (Line goes from left to right):**
        `α ≥ (xmax - x1) / (x2 - x1)`
    *   **Case 3: (x2-x1) = 0: ** The line is vertical.
        *   If `x1 > xmax`, the line is totally on the right of the boundary and outside the window.
        *   If `x1 < xmax`, the line is totally on the left of the boundary and can be inside the window.

3.  **Bottom Boundary (y = ymin):**

    *   We need `ymin ≤ y = y1 + α(y2 - y1)`
    *   Rearranging, we get `ymin - y1 ≤ α(y2 - y1)`

    Cases:

    *   **(y2 - y1) < 0:** `α ≥ (ymin - y1) / (y2 - y1)`
    *   **(y2 - y1) > 0:** `α ≤ (ymin - y1) / (y2 - y1)`
    *   **(y2-y1) = 0: ** The line is horizontal.
        *   If `y1 < ymin`, the line is totally below the boundary and outside the window.
        *   If `y1 > ymin`, the line is totally above the boundary and can be inside the window.

4.  **Top Boundary (y = ymax):**

    *   We need `y = y1 + α(y2 - y1) ≤ ymax`
    *   Rearranging, we get `α(y2 - y1) ≤ ymax - y1`

    Cases:

    *   **(y2 - y1) < 0:** `α ≤ (ymax - y1) / (y2 - y1)`
    *   **(y2 - y1) > 0:** `α ≥ (ymax - y1) / (y2 - y1)`
    *   **(y2-y1) = 0: ** The line is horizontal.
        *   If `y1 > ymax`, the line is totally above the boundary and outside the window.
        *   If `y1 < ymax`, the line is totally below the boundary and can be inside the window.

**Defining p and q**

To summarize the inequalities, it's common to introduce the following notation:

*   `p1 = -(x2 - x1)`
*   `p2 = (x2 - x1)`
*   `p3 = -(y2 - y1)`
*   `p4 = (y2 - y1)`

*   `q1 = (x1 - xmin)`
*   `q2 = (xmax - x1)`
*   `q3 = (y1 - ymin)`
*   `q4 = (ymax - y1)`

Using these `p` and `q` values, the constraints become:

*   For `pk < 0`: `α ≥ qk / pk`
*   For `pk > 0`: `α ≤ qk / pk`
*   For `pk = 0`: The line is parallel to that boundary.  If `qk < 0`, the line is entirely outside the window and can be discarded.  If `qk >= 0`, the line *might* be inside, so consider the other boundaries.

**Algorithm Steps**

1.  **Calculate `p` and `q` values:**  Compute `p1`, `p2`, `p3`, `p4` and `q1`, `q2`, `q3`, `q4` as defined above.

2.  **Initialize `αmin` and `αmax`:**
    *   `αmin = 0`  (The initial minimum value of alpha, corresponding to the start point of the segment)
    *   `αmax = 1`  (The initial maximum value of alpha, corresponding to the end point of the segment)

3.  **Iterate through the boundaries (k = 1 to 4):**

    *   **If `pk = 0`:**  The line is parallel to this boundary.
        *   If `qk < 0`, the line is entirely outside the clipping window.  Reject the line and stop.
        *   If `qk >= 0`, continue to the next boundary.  This boundary does not affect the clipping.

    *   **If `pk < 0`:**
        *   `α = qk / pk`
        *   If `α > αmax`, the line is entirely outside the clipping window. Reject the line and stop.
        *   If `α > αmin`, then update `αmin = α` (we've found a larger minimum alpha value that clips the line).

    *   **If `pk > 0`:**
        *   `α = qk / pk`
        *   If `α < αmin`, the line is entirely outside the clipping window. Reject the line and stop.
        *   If `α < αmax`, then update `αmax = α` (we've found a smaller maximum alpha value that clips the line).

4.  **Check if `αmin > αmax`:** If this is true, the line is entirely outside the clip window. Reject the line.

5.  **Determine the Clipped Line Segment:**

    *   If the algorithm hasn't been stopped (i.e., the line is at least partially visible), calculate the new endpoints of the clipped line segment:

        *   `x1' = x1 + αmin * (x2 - x1)`
        *   `y1' = y1 + αmin * (y2 - y1)`
        *   `x2' = x1 + αmax * (x2 - x1)`
        *   `y2' = y1 + αmax * (y2 - y1)`

    *   The line segment with endpoints `(x1', y1')` and `(x2', y2')` is the visible portion of the original line segment within the clipping window.

**Example**

Let's say we have a line segment with endpoints `(x1, y1) = (50, 50)` and `(x2, y2) = (150, 150)`, and the clipping window is defined by `xmin = 75`, `xmax = 125`, `ymin = 75`, `ymax = 125`.

1.  **Calculate `p` and `q`:**

    *   `p1 = -(150 - 50) = -100`
    *   `p2 = (150 - 50) = 100`
    *   `p3 = -(150 - 50) = -100`
    *   `p4 = (150 - 50) = 100`

    *   `q1 = (50 - 75) = -25`
    *   `q2 = (125 - 50) = 75`
    *   `q3 = (50 - 75) = -25`
    *   `q4 = (125 - 50) = 75`

2.  **Initialize:** `αmin = 0`, `αmax = 1`

3.  **Iterate through boundaries:**

    *   **k = 1 (Left):** `p1 = -100 < 0`, `α = q1 / p1 = -25 / -100 = 0.25`
        *   `α > αmin` (0.25 > 0), so `αmin = 0.25`
    *   **k = 2 (Right):** `p2 = 100 > 0`, `α = q2 / p2 = 75 / 100 = 0.75`
        *   `α < αmax` (0.75 < 1), so `αmax = 0.75`
    *   **k = 3 (Bottom):** `p3 = -100 < 0`, `α = q3 / p3 = -25 / -100 = 0.25`
        *   `α > αmin` (0.25 > 0.25 is false, but the values are equal. This doesn't change the result.  Some implementations will have the logic set up to include the equality case, and that is perfectly valid).
    *   **k = 4 (Top):** `p4 = 100 > 0`, `α = q4 / p4 = 75 / 100 = 0.75`
        *   `α < αmax` (0.75 < 0.75 is false, but the values are equal. This doesn't change the result.  Some implementations will have the logic set up to include the equality case, and that is perfectly valid).

4.  **Check:** `αmin = 0.25`, `αmax = 0.75`.  `αmin <= αmax`.

5.  **Calculate Clipped Endpoints:**

    *   `x1' = 50 + 0.25 * (150 - 50) = 50 + 25 = 75`
    *   `y1' = 50 + 0.25 * (150 - 50) = 50 + 25 = 75`
    *   `x2' = 50 + 0.75 * (150 - 50) = 50 + 75 = 125`
    *   `y2' = 50 + 0.75 * (150 - 50) = 50 + 75 = 125`

    The clipped line segment has endpoints `(75, 75)` and `(125, 125)`.

**Advantages of Liang-Barsky over Cohen-Sutherland**

*   **Efficiency:** Liang-Barsky can be more efficient than Cohen-Sutherland, especially when a large portion of the line is inside the clip window. Cohen-Sutherland performs multiple clip tests and intersection calculations that can be avoided with the Liang-Barsky approach. Liang-Barsky calculates the `p` and `q` values once and reuses them for each boundary.  It also performs relatively few divisions.
*   **Parametric Form:** The parametric form allows for a more straightforward calculation of the clipped endpoints.
*   **Rejection:**  Liang-Barsky often rejects lines more quickly because it can determine the entire line is outside the window without calculating the intersections.

**In summary, the Liang-Barsky algorithm is an efficient and elegant approach to line clipping that leverages the parametric representation of lines to minimize the number of calculations required.**  It's a valuable tool in computer graphics.


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
