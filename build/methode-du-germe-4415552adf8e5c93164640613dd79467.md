# Methode du germe

The **"Remplissage de régions (méthode du germe)"** is one of the methods listed for performing "Remplissage". The general purpose of **"Remplissage"** is to **fill projected 2D polygons** to give objects a more realistic appearance, typically following a shading model like Gouraud, Phong, or Lambert.

The seed method specifically addresses **regions defined by a boundary**. Its core principle is to start from an **interior pixel** within the region to be filled (referred to as a **"germe"** or seed) and then **recursively propagate the fill colour** to the neighbours of this pixel until the boundary is reached.

The sources describe the process during **each iteration**:

1.  **Horizontal Filling**: For the current seed pixel(s), the algorithm **fills all pixels horizontally** to the right and to the left. This horizontal filling continues until a **boundary colour** is encountered.
2.  **Identifying New Seeds**: Among the pixels located **directly above and below** the horizontal line segment(s) that were just filled, the algorithm **searches** for those. The specific pixels identified are those that are the **leftmost** of a **maximal horizontal sequence eligible for filling**. This means finding the start of a continuous horizontal run of pixels on the adjacent scanlines that are inside the region and haven't been filled yet.
3.  **Stacking New Seeds**: These newly identified "leftmost" pixels (which represent the starting points for future filling operations) are then **pushed onto a stack**. These stacked pixels serve as the **"germes" (seeds) for subsequent iterations**, allowing the filling process to continue expanding into unexplored parts of the region.

This iterative process, using a stack to manage the seeds, ensures that the fill colour propagates throughout the entire connected region starting from the initial germe, stopping only when the defined boundary is met.

In the broader context of the graphics pipeline, "Remplissage", including methods like the seed fill, happens after geometric transformations, projection onto the screen plane, and potentially after or alongside pixelisation and visibility/rendering stages.
