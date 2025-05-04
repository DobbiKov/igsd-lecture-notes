
Rendering a 3D Point from World Space to 2D Screen Space

To render a point M(x_M, y_M, z_M) in the “repère univers” (world space) to its projected point m(u_m, v_m) in the “repère de l’écran” (screen space) via a perspective camera C, we need to apply a sequence of geometric transformations as part of the graphics pipeline. These transformations change the coordinate system the point is defined in. The overall process can be described using homogeneous coordinates and matrix multiplications.

🎯 Essential Parameters
	•	The 3D Point M: The coordinates (x_M, y_M, z_M) of the point in the world coordinate system (repère univers). This is the input to the rendering process.
	•	The Perspective Camera C: The camera defines the viewpoint and how the 3D scene is projected onto a 2D image plane. Its parameters include:
	•	Position: The location (Tx_C, Ty_C, Tz_C) of the camera’s origin in the world coordinate system.
	•	Orientation: The direction the camera is looking and its “up” direction. This can be defined by a rotation R_C that transforms points from the camera’s local coordinate system to the world coordinate system.
	•	Perspective Projection Parameters: These define the view frustum, which is the region of space visible to the camera. For a perspective projection, this is typically a truncated pyramid. The sources define the frustum using the coordinates of its planes: left (l), right (r), bottom (b), top (t), near (n), and far (f).
	•	The Screen or Viewport: This defines the 2D rectangular area on the display device where the final image is drawn. Its parameters include:
	•	Width (W) and Height (H): The dimensions of the viewport in pixels. This defines the mapping from the normalised projection space to the pixel coordinates on the screen.

⸻

🧮 Transformation Pipeline

The rendering process involves transforming the point M through several coordinate systems using matrix multiplications. Homogeneous coordinates, using 4×4 matrices for 3D points represented as 4D vectors (x, y, z, 1), allow translation, rotation, scaling, and perspective projection to all be performed via matrix multiplication.

Step 1: World to Camera Transformation (Viewing Transformation)

This transformation changes the point’s coordinates from the world space to the camera’s local space (also called eye space or view space). This is equivalent to transforming the entire world such that the camera is positioned at the origin (0,0,0) and oriented along standard axes (e.g., looking down the negative Z-axis).

The matrix performing this transformation, M_{\text{view}}, is the inverse of the matrix that transforms points from the camera’s coordinate system into the world coordinate system.

If the camera’s position in world space is given by the translation vector T_C = (Tx_C, Ty_C, Tz_C) and its orientation by the rotation matrix R_C, the transformation from world to camera space is given by:

T(-T_C) = \begin{pmatrix}
1 & 0 & 0 & -Tx_C \\
0 & 1 & 0 & -Ty_C \\
0 & 0 & 1 & -Tz_C \\
0 & 0 & 0 & 1
\end{pmatrix}

The homogeneous rotation matrix R_C incorporates the camera’s orientation. Its transpose R_C^T performs the inverse rotation, aligning the world axes with the camera’s axes.

So:

\mathbf{M_{view}} = \mathbf{R_C^T} \cdot \mathbf{T(-Tx_C, -Ty_C, -Tz_C)}

The point M in homogeneous world coordinates is:

P_{world} = \begin{pmatrix} x_M \\ y_M \\ z_M \\ 1 \end{pmatrix}

And the point in camera space:

P_{camera} = M_{view} \cdot P_{world}



⸻

Step 2: Camera to Clip Space Transformation (Projection Transformation)

This transformation converts the point’s coordinates from the camera’s 3D space into a 3D space suitable for clipping and the perspective divide.

The perspective projection matrix is:

\mathbf{M_{persp\_proj}} = \begin{pmatrix}
\frac{2}{r-l} & 0 & \frac{l+r}{r-l} & 0 \\
0 & \frac{2}{t-b} & \frac{b+t}{t-b} & 0 \\
0 & 0 & -\frac{f+n}{f-n} & -\frac{2fn}{f-n} \\
0 & 0 & -1 & 0
\end{pmatrix}

Then:

P_{clip} = M_{persp\_proj} \cdot P_{camera}

Let:

P_{clip} = \begin{pmatrix} X_c \\ Y_c \\ Z_c \\ W_c \end{pmatrix}



⸻

Step 3: Perspective Division

Divide by W_c to get Normalised Device Coordinates (NDC):

(x_{ndc}, y_{ndc}, z_{ndc}) = \left(\frac{X_c}{W_c}, \frac{Y_c}{W_c}, \frac{Z_c}{W_c}\right)



⸻

Step 4: Clipping

A point is visible if:

-1 \le x_{ndc}, y_{ndc}, z_{ndc} \le 1

Otherwise, it is discarded.

⸻

Step 5: NDC to Screen Space (Viewport Transformation)

Viewport matrix:

\mathbf{M_{viewport}} = \begin{pmatrix}
W/2 & 0 & 0 & W/2 \\
0 & H/2 & 0 & H/2 \\
0 & 0 & 1/2 & 1/2 \\
0 & 0 & 0 & 1
\end{pmatrix}

Apply to get:

P_{screen\_hom} = M_{viewport} \cdot P_{clip}

Then:

(u_m, v_m) = \left(\frac{X_s}{W_s}, \frac{Y_s}{W_s}\right)



⸻

🧱 Combined Matrix

The full transformation is:

M_{total} = M_{viewport} \cdot M_{persp\_proj} \cdot M_{view}

Then:

P_{screen\_hom} = M_{total} \cdot P_{world}

Final screen coordinates:

(u_m, v_m) = \left( \frac{X_s}{W_s}, \frac{Y_s}{W_s} \right)



⸻

