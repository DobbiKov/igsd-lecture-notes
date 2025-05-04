Okay, let's detail the process of rendering a 3D point from world space to 2D screen space using a perspective camera, drawing upon the provided sources.

To render a point \(M(x_M, y_M, z_M)\) in the "repère univers" (world space) to its projected point \(m(u_m, v_m)\) in the "repère de l’écran" (screen space) via a perspective camera \(C\), we need to apply a sequence of geometric transformations as part of the graphics pipeline. These transformations change the coordinate system the point is defined in. The overall process can be described using homogeneous coordinates and matrix multiplications.

Here are the essential parameters of the system required to perform this rendering:

*   **The 3D Point \(M\)**: The coordinates \((x_M, y_M, z_M)\) of the point in the world coordinate system (repère univers). This is the input to the rendering process.
*   **The Perspective Camera \(C\)**: The camera defines the viewpoint and how the 3D scene is projected onto a 2D image plane. Its parameters include:
    *   **Position**: The location \((Tx_C, Ty_C, Tz_C)\) of the camera's origin in the world coordinate system.
    *   **Orientation**: The direction the camera is looking and its "up" direction. This can be defined by a rotation \(R_C\) that transforms points from the camera's local coordinate system to the world coordinate system.
    *   **Perspective Projection Parameters**: These define the **view frustum**, which is the region of space visible to the camera. For a perspective projection, this is typically a truncated pyramid. The sources define the frustum using the coordinates of its planes: left (l), right (r), bottom (b), top (t), near (n), and far (f). The near and far planes define the closest and farthest distances from the camera that objects are still rendered.
*   **The Screen or Viewport**: This defines the 2D rectangular area on the display device where the final image is drawn. Its parameters include:
    *   **Width (W) and Height (H)**: The dimensions of the viewport in pixels. This defines the mapping from the normalised projection space to the pixel coordinates on the screen.

The rendering process involves transforming the point \(M\) through several coordinate systems using matrix multiplications. Homogeneous coordinates, using 4x4 matrices for 3D points represented as 4D vectors \((x, y, z, 1)\), allow translation, rotation, scaling, and perspective projection to all be performed via matrix multiplication.

Here are the necessary transformations, step by step, detailed with homogeneous coordinate matrices:

**Step 1: World to Camera Transformation (Viewing Transformation)**

This transformation changes the point's coordinates from the world space to the camera's local space (also called eye space or view space). This is equivalent to transforming the entire world such that the camera is positioned at the origin \((0,0,0)\) and oriented along standard axes (e.g., looking down the negative Z-axis).

The matrix performing this transformation, \(M_{view}\), is the inverse of the matrix that transforms points from the camera's coordinate system into the world coordinate system. If the camera's position in world space is given by the translation vector \(T_C = (Tx_C, Ty_C, Tz_C)\) and its orientation by the rotation matrix \(R_C\) (which transforms camera-space vectors to world-space vectors), the transformation from world to camera space is given by \(M_{view} = R_C^T \cdot T(-T_C)\).

The homogeneous translation matrix to move the world so the camera is at the origin is:
\(T(-T_C) = \begin{pmatrix} 1 & 0 & 0 & -Tx_C \\ 0 & 1 & 0 & -Ty_C \\ 0 & 0 & 1 & -Tz_C \\ 0 & 0 & 0 & 1 \end{pmatrix}\).

The homogeneous rotation matrix \(R_C\) incorporates the camera's orientation. Its transpose \(R_C^T\) performs the inverse rotation, aligning the world axes with the camera's axes. \(R_C^T\) is the inverse for rotation matrices. If \(R_C\) is a 4x4 homogeneous rotation matrix (with the bottom-right element being 1 and the rest of the last row/column being 0 except for the 3x3 rotation part), then \(R_C^T\) is simply its transpose.

The World to Camera transformation matrix is therefore:
\(\mathbf{M_{view}} = \mathbf{R_C^T} \cdot \mathbf{T(-Tx_C, -Ty_C, -Tz_C)}\)

The point \(M\) in homogeneous world coordinates is \(P_{world} = \begin{pmatrix} x_M \\ y_M \\ z_M \\ 1 \end{pmatrix}\).
The point in camera space homogeneous coordinates is \(P_{camera} = M_{view} \cdot P_{world}\).

**Step 2: Camera to Clip Space Transformation (Projection Transformation)**

This transformation converts the point's coordinates from the camera's 3D space into a 3D space suitable for **clipping** and the subsequent perspective divide. It projects the 3D geometry onto a 2D plane while preserving depth information for visibility tests. For a perspective projection, this matrix implements the foreshortening effect (objects appearing smaller further away). The source material includes a specific matrix for the perspective projection that maps the view frustum (defined by l, r, b, t, n, f) into a **Normalised Device Coordinates (NDC)** cube, typically ranging from \(-1\) to \(1\) along each axis. Clipping is often performed after this step in NDC space.

The full perspective projection matrix provided in the sources, mapping from camera space (view frustum) to NDC is:
\(\mathbf{M_{persp\_proj}} = \begin{pmatrix} \frac{2}{r-l} & 0 & \frac{l+r}{r-l} & 0 \\ 0 & \frac{2}{t-b} & \frac{b+t}{t-b} & 0 \\ 0 & 0 & -\frac{f+n}{f-n} & -\frac{2fn}{f-n} \\ 0 & 0 & -1 & 0 \end{pmatrix}\).

The point in clip space homogeneous coordinates is \(P_{clip} = M_{persp\_proj} \cdot P_{camera}\).
Let \(P_{clip} = \begin{pmatrix} X_c \\ Y_c \\ Z_c \\ W_c \end{pmatrix}\).

**Step 3: Perspective Division**

After the projection matrix is applied, the points are in homogeneous clip coordinates \((X_c, Y_c, Z_c, W_c)\). The perspective effect is completed by dividing the X, Y, and Z components by the W component to get the 3D NDC coordinates \((x_{ndc}, y_{ndc}, z_{ndc}) = (X_c/W_c, Y_c/W_c, Z_c/W_c)\). This division is not a matrix multiplication applied to the vector itself, but rather a fundamental part of using homogeneous coordinates for perspective transformations.

**Step 4: Clipping**

Clipping is the process of removing geometry that lies outside the **viewing volume** (the frustum). After the perspective projection and division, points are in NDC space. The viewing volume in NDC is a cube defined by the ranges \([-1, 1]\) for x, y, and z. A point is visible if and only if its NDC coordinates satisfy \(-1 \le x_{ndc} \le 1\), \(-1 \le y_{ndc} \le 1\), and \(-1 \le z_{ndc} \le 1\). If the point is outside this range, it is discarded from the pipeline; otherwise, it proceeds to the next stage. This is typically a test and discard step, not a matrix transformation of the point's coordinates.

**Step 5: NDC to Screen Transformation (Viewport Transformation)**

This final transformation maps the point's coordinates from the NDC space to the 2D screen space (pixel coordinates). The NDC coordinates range from \(-1\) to \(1\). The screen coordinates typically range from \(0\) to the screen width (W) for the x-axis and \(0\) to the screen height (H) for the y-axis. This transformation involves scaling and translating the NDC coordinates to fit the defined screen viewport. It also typically maps the NDC z coordinate (which is in \([-1, 1]\)) to a depth value (e.g., in \(\) or \([0, 2^{buffer\_bits}-1]\)) for use in the depth buffer (Z-buffer) during the visibility/rendering step.

The homogeneous transformation matrix \(\mathbf{M_{viewport}}\) mapping NDC \([-1, 1]\) to screen coordinates \([0, W]\) for x and \([0, H]\) for y (and \([-1, 1]\) to \(\) for depth) is:
\(\mathbf{M_{viewport}} = \begin{pmatrix} W/2 & 0 & 0 & W/2 \\ 0 & H/2 & 0 & H/2 \\ 0 & 0 & 1/2 & 1/2 \\ 0 & 0 & 0 & 1 \end{pmatrix}\).
Note: The standard transformation maps NDC z \([-1, 1]\) to depth \(\) for the Z-buffer, which is why the third row uses a scale of 1/2 and translate of 1/2. For just the 2D screen coordinates (u, v), only the first two rows are directly relevant after the final homogeneous division.

The point in screen space homogeneous coordinates (before the final division by Ws) is obtained by applying the viewport matrix to the clip space homogeneous point: \(P_{screen\_hom} = M_{viewport} \cdot P_{clip}\).
Let \(P_{screen\_hom} = \begin{pmatrix} X_s \\ Y_s \\ Z_s \\ W_s \end{pmatrix}\).
The final 2D screen coordinates \((u_m, v_m)\) are given by \((u_m, v_m) = (\frac{X_s}{W_s}, \frac{Y_s}{W_s})\). These coordinates define the pixel location on the screen.

**Combined Transformation Matrix**

The complete transformation of the point \(M\) from world space to homogeneous screen space (before the final division) is achieved by multiplying the point's homogeneous world coordinate vector by the sequence of transformation matrices:

\(P_{screen\_hom} = \mathbf{M_{viewport}} \cdot \mathbf{M_{persp\_proj}} \cdot \mathbf{M_{view}} \cdot P_{world}\).

The product of the canonical matrices performing the transformations from world space to homogeneous screen space is:

\(\mathbf{M_{total}} = \mathbf{M_{viewport}} \cdot \mathbf{M_{persp\_proj}} \cdot \mathbf{M_{view}}\)

\(\mathbf{M_{total}} = \begin{pmatrix} W/2 & 0 & 0 & W/2 \\ 0 & H/2 & 0 & H/2 \\ 0 & 0 & 1/2 & 1/2 \\ 0 & 0 & 0 & 1 \end{pmatrix} \cdot \begin{pmatrix} \frac{2}{r-l} & 0 & \frac{l+r}{r-l} & 0 \\ 0 & \frac{2}{t-b} & \frac{b+t}{t-b} & 0 \\ 0 & 0 & -\frac{f+n}{f-n} & -\frac{2fn}{f-n} \\ 0 & 0 & -1 & 0 \end{pmatrix} \cdot (\mathbf{R_C^T} \cdot \begin{pmatrix} 1 & 0 & 0 & -Tx_C \\ 0 & 1 & 0 & -Ty_C \\ 0 & 0 & 1 & -Tz_C \\ 0 & 0 & 0 & 1 \end{pmatrix})\)

where \(R_C^T\) is the transpose of the camera's 4x4 homogeneous rotation matrix.

To get the final 2D screen coordinates \((u_m, v_m)\), you would multiply the point \(P_{world}\) by \(M_{total}\) to get \(P_{screen\_hom} = (X_s, Y_s, Z_s, W_s)^T\), and then perform the perspective divide: \(u_m = X_s / W_s\) and \(v_m = Y_s / W_s\). The Z_s/W_s value can be used for depth testing.
