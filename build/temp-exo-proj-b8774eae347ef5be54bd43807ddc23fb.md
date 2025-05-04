Okay, let’s detail the process of rendering a 3D point from world space to 2D screen space using a perspective camera, drawing upon the provided sources.

To render a point $M(x_M, y_M, z_M)$ in the “repère univers” (world space) to its projected point $m(u_m, v_m)$ in the “repère de l’écran” (screen space) via a perspective camera $C$, we need to apply a sequence of geometric transformations as part of the graphics pipeline. These transformations change the coordinate system the point is defined in. The overall process can be described using homogeneous coordinates and matrix multiplications.

Here are the essential parameters of the system required to perform this rendering:

- **The 3D Point $M$**: The coordinates $(x_M, y_M, z_M)$ of the point in the world coordinate system (repère univers). This is the input to the rendering process.  
- **The Perspective Camera $C$**: The camera defines the viewpoint and how the 3D scene is projected onto a 2D image plane. Its parameters include:  
  - **Position**: The location $(T\!x_C, T\!y_C, T\!z_C)$ of the camera’s origin in the world coordinate system.  
  - **Orientation**: The direction the camera is looking and its “up” direction. This can be defined by a rotation $R_C$ that transforms points from the camera’s local coordinate system to the world coordinate system.  
  - **Perspective Projection Parameters**: These define the **view frustum**, which is the region of space visible to the camera. For a perspective projection, this is typically a truncated pyramid. The sources define the frustum using the coordinates of its planes: left ($l$), right ($r$), bottom ($b$), top ($t$), near ($n$), and far ($f$). The near and far planes define the closest and farthest distances from the camera that objects are still rendered.  
- **The Screen or Viewport**: This defines the 2D rectangular area on the display device where the final image is drawn. Its parameters include:  
  - **Width (W) and Height (H)**: The dimensions of the viewport in pixels. This defines the mapping from the normalised projection space to the pixel coordinates on the screen.  

The rendering process involves transforming the point $M$ through several coordinate systems using matrix multiplications. Homogeneous coordinates, using 4×4 matrices for 3D points represented as 4D vectors $(x, y, z, 1)$, allow translation, rotation, scaling, and perspective projection to all be performed via matrix multiplication.

Here are the necessary transformations, step by step, detailed with homogeneous-coordinate matrices:

## Step 1: World to Camera Transformation (Viewing Transformation)

This transformation changes the point’s coordinates from the world space to the camera’s local space (also called eye space or view space). This is equivalent to transforming the entire world such that the camera is positioned at the origin $(0,0,0)$ and oriented along standard axes (e.g., looking down the negative Z‑axis).

The matrix performing this transformation, $M_{\mathrm{view}}$, is the inverse of the matrix that transforms points from the camera’s coordinate system into the world coordinate system. If the camera’s position in world space is given by the translation vector $T_C = (T\!x_C, T\!y_C, T\!z_C)$ and its orientation by the rotation matrix $R_C$ (which transforms camera‑space vectors to world‑space vectors), the transformation from world to camera space is given by
$$
M_{\mathrm{view}} \;=\; R_C^T \,\cdot\, T(-T_C).
$$

The homogeneous translation matrix to move the world so the camera is at the origin is:
```math
T(-T_C) = \begin{pmatrix}
1 & 0 & 0 & -T\!x_C \\
0 & 1 & 0 & -T\!y_C \\
0 & 0 & 1 & -T\!z_C \\
0 & 0 & 0 & 1
\end{pmatrix}
```

The homogeneous rotation matrix $R_C$ incorporates the camera’s orientation. Its transpose $R_C^T$ performs the inverse rotation, aligning the world axes with the camera’s axes. If $R_C$ is a 4×4 homogeneous rotation matrix (with the bottom‑right element being 1 and the rest of the last row/column being 0 except for the 3×3 rotation part), then $R_C^T$ is simply its transpose.

The World → Camera transformation matrix is therefore:

M_{\mathrm{view}} = R_C^T \,\cdot\, T(-T_C)

The point $M$ in homogeneous world coordinates is

P_{\mathrm{world}} = \begin{pmatrix}
x_M \\
y_M \\
z_M \\
1
\end{pmatrix}.

The point in camera‑space homogeneous coordinates is

P_{\mathrm{camera}} = M_{\mathrm{view}} \,\cdot\, P_{\mathrm{world}}.

Step 2: Camera to Clip Space Transformation (Projection Transformation)

This transformation converts the point’s coordinates from the camera’s 3D space into a 3D space suitable for clipping and the subsequent perspective divide. It projects the 3D geometry onto a 2D plane while preserving depth information for visibility tests. For a perspective projection, this matrix implements the foreshortening effect (objects appearing smaller further away). The source material includes a specific matrix for the perspective projection that maps the view frustum (defined by $l, r, b, t, n, f$) into a Normalised Device Coordinates (NDC) cube, typically ranging from –1 to 1 along each axis.

The full perspective projection matrix provided in the sources, mapping from camera space (view frustum) to NDC is:

M_{\mathrm{persp\_proj}} = \begin{pmatrix}
\frac{2}{r - l} & 0 & \frac{l + r}{r - l} & 0 \\
0 & \frac{2}{t - b} & \frac{b + t}{t - b} & 0 \\
0 & 0 & -\frac{f + n}{f - n} & -\frac{2 f n}{f - n} \\
0 & 0 & -1 & 0
\end{pmatrix}

The point in clip‑space homogeneous coordinates is

P_{\mathrm{clip}} = M_{\mathrm{persp\_proj}} \,\cdot\, P_{\mathrm{camera}}.

Let

P_{\mathrm{clip}} = \begin{pmatrix} X_c \\ Y_c \\ Z_c \\ W_c \end{pmatrix}.

Step 3: Perspective Division

After the projection matrix is applied, the points are in homogeneous clip coordinates $(X_c, Y_c, Z_c, W_c)$. The perspective effect is completed by dividing the X, Y, and Z components by the W component to get the 3D NDC coordinates:
[
(x_{\mathrm{ndc}},,y_{\mathrm{ndc}},,z_{\mathrm{ndc}})
;=;
\bigl(X_c/W_c,;Y_c/W_c,;Z_c/W_c\bigr).
]

Step 4: Clipping

Clipping is the process of removing geometry that lies outside the viewing volume (the frustum). After the perspective projection and division, points are in NDC space. The viewing volume in NDC is a cube defined by the ranges $[-1,1]$ for $x$, $y$, and $z$. A point is visible if and only if
[
-1 ,\le, x_{\mathrm{ndc}} ,\le, 1,\quad
-1 ,\le, y_{\mathrm{ndc}} ,\le, 1,\quad
-1 ,\le, z_{\mathrm{ndc}} ,\le, 1.
]
If the point is outside this range, it is discarded from the pipeline; otherwise, it proceeds to the next stage.

Step 5: NDC to Screen Transformation (Viewport Transformation)

This final transformation maps the point’s coordinates from the NDC space to the 2D screen space (pixel coordinates). The NDC coordinates range from –1 to 1. The screen coordinates typically range from 0 to the screen width (W) for the x‑axis and 0 to the screen height (H) for the y‑axis. This transformation involves scaling and translating the NDC coordinates to fit the defined screen viewport. It also typically maps the NDC $z$ coordinate (which is in $[-1,1]$) to a depth value (e.g., in $[0,2^{\mathrm{buffer_bits}}-1]$) for use in the depth buffer (Z‑buffer) during the visibility/rendering step.

The homogeneous transformation matrix $M_{\mathrm{viewport}}$ mapping NDC $[-1,1]$ to screen coordinates $[0,W]$ for $x$ and $[0,H]$ for $y$ (and $[-1,1]$ to $[0,1]$ for depth) is:

M_{\mathrm{viewport}} = \begin{pmatrix}
W/2 & 0   & 0   & W/2 \\
0   & H/2 & 0   & H/2 \\
0   & 0   & 1/2 & 1/2 \\
0   & 0   & 0   & 1
\end{pmatrix}

	Note: The standard transformation maps NDC $z\in[-1,1]$ to depth $\in[0,1]$ for the Z‑buffer, which is why the third row uses a scale of 1/2 and translate of 1/2. For just the 2D screen coordinates $(u,v)$, only the first two rows are directly relevant after the final homogeneous division.

The point in screen‑space homogeneous coordinates (before the final division by $W_s$) is obtained by applying the viewport matrix to the clip‑space homogeneous point:

P_{\mathrm{screen\_hom}} = M_{\mathrm{viewport}} \,\cdot\, P_{\mathrm{clip}}

Let

P_{\mathrm{screen\_hom}} = \begin{pmatrix}
X_s \\ Y_s \\ Z_s \\ W_s
\end{pmatrix}.

The final 2D screen coordinates $(u_m, v_m)$ are given by
[
(u_m,,v_m) = \bigl(X_s / W_s,;Y_s / W_s\bigr).
]

Combined Transformation Matrix

The complete transformation of the point $M$ from world space to homogeneous screen space (before the final division) is achieved by multiplying the point’s homogeneous world coordinate vector by the sequence of transformation matrices:

P_{\mathrm{screen\_hom}}
= M_{\mathrm{viewport}}
  \;\cdot\;
  M_{\mathrm{persp\_proj}}
  \;\cdot\;
  M_{\mathrm{view}}
  \;\cdot\;
  P_{\mathrm{world}}.

The product of the canonical matrices performing the transformations from world space to homogeneous screen space is:

M_{\mathrm{total}}
= M_{\mathrm{viewport}}
  \;\cdot\;
  M_{\mathrm{persp\_proj}}
  \;\cdot\;
  M_{\mathrm{view}}.

M_{\mathrm{total}}
= \begin{pmatrix}
W/2 & 0   & 0   & W/2 \\
0   & H/2 & 0   & H/2 \\
0   & 0   & 1/2 & 1/2 \\
0   & 0   & 0   & 1
\end{pmatrix}
\;\cdot\;
\begin{pmatrix}
\frac{2}{r - l} & 0 & \frac{l + r}{r - l} & 0 \\
0 & \frac{2}{t - b} & \frac{b + t}{t - b} & 0 \\
0 & 0 & -\frac{f + n}{f - n} & -\frac{2 f n}{f - n} \\
0 & 0 & -1 & 0
\end{pmatrix}
\;\cdot\;
\Bigl(
R_C^T
\;\cdot\;
\begin{pmatrix}
1 & 0 & 0 & -T\!x_C \\
0 & 1 & 0 & -T\!y_C \\
0 & 0 & 1 & -T\!z_C \\
0 & 0 & 0 & 1
\end{pmatrix}
\Bigr).

To get the final 2D screen coordinates $(u_m, v_m)$, multiply $P_{\mathrm{world}}$ by $M_{\mathrm{total}}$ to get $P_{\mathrm{screen_hom}}=(X_s,Y_s,Z_s,W_s)^T$, then perform the perspective divide:
[
u_m = \frac{X_s}{W_s}, \quad v_m = \frac{Y_s}{W_s}.
]
The value $\frac{Z_s}{W_s}$ can be used for depth testing.
