# Projecting point onto the screen
:::{important} Exercise 2
On doit faire le rendu d’un point \( M(x_M, y_M, z_M) \) dans le repère univers vers son point projeté \( m(u_m, v_m) \) dans le repère de l’écran 2D via une caméra perspective \( C \). Identifier tous les paramètres du système pour pouvoir effectuer ce rendu. Détailer sous forme de matrices de coordonnées homogènes l’ensemble des transformations nécessaires pour le rendu. Il faudra donner simplement le produit des matrices canoniques sans en effectuer le calcul.
:::
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

###  Step 1: World to Camera Transformation (Viewing Transformation)

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

$$
M_{\mathrm{view}} = R_C^T \,\cdot\, T(-T_C)
$$

The point $M$ in homogeneous world coordinates is

$$
P_{\mathrm{world}} = \begin{pmatrix}
x_M \\
y_M \\
z_M \\
1
\end{pmatrix}.
$$

The point in camera‑space homogeneous coordinates is

$$
P_{\mathrm{camera}} = M_{\mathrm{view}} \,\cdot\, P_{\mathrm{world}}.
$$

### Step 2: Camera to Clip Space Transformation (Projection Transformation)

This transformation converts the point’s coordinates from the camera’s 3D space into a 3D space suitable for clipping and the subsequent perspective divide. It projects the 3D geometry onto a 2D plane while preserving depth information for visibility tests. For a perspective projection, this matrix implements the foreshortening effect (objects appearing smaller further away). The source material includes a specific matrix for the perspective projection that maps the view frustum (defined by $l, r, b, t, n, f$) into a Normalised Device Coordinates (NDC) cube, typically ranging from –1 to 1 along each axis.

The full perspective projection matrix provided in the sources, mapping from camera space (view frustum) to NDC is:

$$
M_{\mathrm{persp\_proj}} = \begin{pmatrix}
\frac{2}{r - l} & 0 & \frac{l + r}{r - l} & 0 \\
0 & \frac{2}{t - b} & \frac{b + t}{t - b} & 0 \\
0 & 0 & -\frac{f + n}{f - n} & -\frac{2 f n}{f - n} \\
0 & 0 & -1 & 0
\end{pmatrix}
$$

The point in clip‑space homogeneous coordinates is

$$
P_{\mathrm{clip}} = M_{\mathrm{persp\_proj}} \,\cdot\, P_{\mathrm{camera}}.
$$

Let

$$
P_{\mathrm{clip}} = \begin{pmatrix} X_c \\ Y_c \\ Z_c \\ W_c \end{pmatrix}.
$$

Step 3: Perspective Division

After the projection matrix is applied, the points are in homogeneous clip coordinates $(X_c, Y_c, Z_c, W_c)$. The perspective effect is completed by dividing the X, Y, and Z components by the W component to get the 3D NDC coordinates:
($x_{\mathrm{ndc}},,y_{\mathrm{ndc}},,z_{\mathrm{ndc}}$)
$$
\bigl(X_c/W_c,;Y_c/W_c,;Z_c/W_c\bigr).
$$


### Step 4: Clipping

Clipping is the process of removing geometry that lies outside the viewing volume (the frustum). After the perspective projection and division, points are in NDC space. The viewing volume in NDC is a cube defined by the ranges $[-1,1]$ for $x$, $y$, and $z$. A point is visible if and only if
$$
-1 ,\le, x_{\mathrm{ndc}} ,\le, 1,\quad
-1 ,\le, y_{\mathrm{ndc}} ,\le, 1,\quad
-1 ,\le, z_{\mathrm{ndc}} ,\le, 1.
$$

If the point is outside this range, it is discarded from the pipeline; otherwise, it proceeds to the next stage.

Step 5: NDC to Screen Transformation (Viewport Transformation)

This final transformation maps the point’s coordinates from the NDC space to the 2D screen space (pixel coordinates). The NDC coordinates range from –1 to 1. The screen coordinates typically range from 0 to the screen width (W) for the x‑axis and 0 to the screen height (H) for the y‑axis. This transformation involves scaling and translating the NDC coordinates to fit the defined screen viewport. It also typically maps the NDC $z$ coordinate (which is in $[-1,1]$) to a depth value (e.g., in $[0,2^{\mathrm{buffer_bits}}-1]$) for use in the depth buffer (Z‑buffer) during the visibility/rendering step.

The homogeneous transformation matrix $M_{\mathrm{viewport}}$ mapping NDC $[-1,1]$ to screen coordinates $[0,W]$ for $x$ and $[0,H]$ for $y$ (and $[-1,1]$ to $[0,1]$ for depth) is:

$$
M_{\mathrm{viewport}} = \begin{pmatrix}
W/2 & 0   & 0   & W/2 \\
0   & H/2 & 0   & H/2 \\
0   & 0   & 1/2 & 1/2 \\
0   & 0   & 0   & 1
\end{pmatrix}
$$

	Note: The standard transformation maps NDC $z\in[-1,1]$ to depth $\in[0,1]$ for the Z‑buffer, which is why the third row uses a scale of 1/2 and translate of 1/2. For just the 2D screen coordinates $(u,v)$, only the first two rows are directly relevant after the final homogeneous division.

The point in screen‑space homogeneous coordinates (before the final division by $W_s$) is obtained by applying the viewport matrix to the clip‑space homogeneous point:

$$
P_{\mathrm{screen\_hom}} = M_{\mathrm{viewport}} \,\cdot\, P_{\mathrm{clip}}
$$

Let
$$
P_{\mathrm{screen\_hom}} = \begin{pmatrix}
X_s \\ Y_s \\ Z_s \\ W_s
\end{pmatrix}.
$$

The final 2D screen coordinates $(u_m, v_m)$ are given by
$$
(u_m,,v_m) = \bigl(X_s / W_s,;Y_s / W_s\bigr).
$$

Combined Transformation Matrix

The complete transformation of the point $M$ from world space to homogeneous screen space (before the final division) is achieved by multiplying the point’s homogeneous world coordinate vector by the sequence of transformation matrices:

$$
P_{\mathrm{screen\_hom}}
= M_{\mathrm{viewport}}
  \;\cdot\;
  M_{\mathrm{persp\_proj}}
  \;\cdot\;
  M_{\mathrm{view}}
  \;\cdot\;
  P_{\mathrm{world}}.
$$
The product of the canonical matrices performing the transformations from world space to homogeneous screen space is:
$$
M_{\mathrm{total}}
= M_{\mathrm{viewport}}
  \;\cdot\;
  M_{\mathrm{persp\_proj}}
  \;\cdot\;
  M_{\mathrm{view}}.
$$

$$
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
$$

To get the final 2D screen coordinates $(u_m, v_m)$, multiply $P_{\mathrm{world}}$ by $M_{\mathrm{total}}$ to get $P_{\mathrm{screen_hom}}=(X_s,Y_s,Z_s,W_s)^T$, then perform the perspective divide:
$$
u_m = \frac{X_s}{W_s}, \quad v_m = \frac{Y_s}{W_s}.
$$
The value $\frac{Z_s}{W_s}$ can be used for depth testing.


### Why do matrices have exactly the form they do?
**Understanding Mystmd Syntax**

The user wants me to convert plain text with Markdown code to the mystmd syntax. Mystmd is for Sphinx and supports directives, roles, and math, which means I need to adjust specific elements like headings and math expressions. For example, headings in mystmd use `#`, and bold text stays as `**`, but there could be differences, such as code blocks needing triple backticks (` ``` `). I’ll ensure I don’t change the text, only the syntax.

**Обробка математичних виразів у mystmd**

Мені потрібно перетворити математичні вирази: для inline LaTeX $...$ слід замінити на \$ ... \$, а для відображення $...$ або $...$ використовувати відповідні позначки MyST: для inline виразів — `$...$`, а для відображених — $...$. Здається, MyST підтримує обидва варіанти для математичних ролей та виразів, тому я точно дотримуватимуся цієї синтаксичної структури.

**Перехід до синтаксису MyST**

Я збираюся використовувати заголовки рівня 2 для основних частин, наприклад, для "The Perspective Projection Matrix", залишаючи межі спеціальних математичних вставок. Також, я маю застосувати неправильний відступ для підпунктів і перевести стиль на MyST. Наприклад, я використаю для математичних виразів знаки \$...\$. Також потрібно переробити всі пункти в марковані списки. Ось як буде виглядати фінальний формат у MyST — це дозволить зрозуміло передати весь текст із синтаксисом Markdown!


Обробка тривала 19 с


That’s an excellent question, delving into the specifics of how these transformation matrices are constructed! The particular form and the coefficients (the numbers and letters) of the `M_viewport` and `M_persp_proj` matrices arise directly from their purpose in the graphics pipeline: mapping coordinates from one defined space to another. Let’s break them down based on the information in the sources.

As we established in our previous conversation and is outlined in the sources, rendering a 3D point involves a sequence of transformations: first moving from the object’s local space to the world space, then from world space to the camera’s space (the viewing transformation), then the projection (transforming 3D primitives onto a 2D image space), followed by clipping, and finally the transformation to screen space (the viewport transformation). Homogeneous coordinates and 4×4 matrices are used to unify these transformations.

## 1. The Perspective Projection Matrix (`M_persp_proj`)

* **Purpose:**
  The perspective projection matrix transforms points from the camera’s 3D view space (eye space) into a standardised 3D space called **Normalised Device Coordinates (NDC)**. This transformation is fundamental to creating the perspective effect, where objects appear smaller the further away they are. The sources mention that the projection process projects 3D primitives onto the 2D image space (screen space).

* **View Frustum Parameters:**
  For a perspective projection, the camera sees a region of space called the **view frustum**. This frustum is shaped like a truncated pyramid. The sources define this frustum using six clipping planes: `left` (l), `right` (r), `bottom` (b), `top` (t), `near` (n), and `far` (f). The near plane (\$z\$-near) and far plane (\$z\$-far) define the boundaries along the depth axis. Objects outside this frustum are clipped (removed).

* **Mapping to NDC:**
  The goal of the perspective projection matrix is to map this view frustum into a canonical cube in NDC space. NDC coordinates typically range from \$-1\$ to \$1\$ along each axis. The transformation ensures that points exactly on the near plane (\$z=-n\$ in camera space) map to \$z\_{\text{ndc}}=-1\$, points exactly on the far plane (\$z=-f\$) map to \$z\_{\text{ndc}}=1\$, points on the left plane (\$x=l\$) map to \$x\_{\text{ndc}}=-1\$, points on the right plane (\$x=r\$) map to \$x\_{\text{ndc}}=1\$, points on the bottom plane (\$y=b\$) map to \$y\_{\text{ndc}}=-1\$, and points on the top plane (\$y=t\$) map to \$y\_{\text{ndc}}=1\$.

* **The Matrix Form:**
  The specific matrix provided in the sources achieves this mapping and prepares the coordinates for the perspective divide:

  $$
  \mathbf{M_{persp\_proj}}
  = 
  \begin{pmatrix}
    \displaystyle \frac{2}{r - l} & 0 & \displaystyle \frac{l + r}{r - l} & 0 \\[1em]
    0 & \displaystyle \frac{2}{t - b} & \displaystyle \frac{b + t}{t - b} & 0 \\[1em]
    0 & 0 & -\displaystyle \frac{f + n}{f - n} & -\displaystyle \frac{2 f n}{f - n} \\[1em]
    0 & 0 & -1 & 0
  \end{pmatrix}
  $$

  * **Top-Left 3×3 Block:**
    Handles the scaling and mapping of the x, y, and z coordinates, while implicitly incorporating the perspective effect.

    * \$\frac{2}{r-l}\$ and \$\frac{l+r}{r-l}\$ map the x-range $\[l,r]\$ to $\[-1,1]\$.
    * \$\frac{2}{t-b}\$ and \$\frac{b+t}{t-b}\$ map the y-range $\[b,t]\$ to $\[-1,1]\$.
    * \$-\frac{f+n}{f-n}\$ and \$-\frac{2fn}{f-n}\$ map the z-range $\[-f,-n]\$ to $\[-1,1]\$ (camera looks down –Z).

  * **Bottom Row \$(0,0,-1,0)\$:**
    Causes the homogeneous w-coordinate to become \$-z\_{\text{camera}}\$, so that after multiplication by the matrix the resulting point \$(X\_c, Y\_c, Z\_c, W\_c)\$ satisfies:

    $$
    x_{\text{ndc}} = \frac{X_c}{W_c} = \frac{X_c}{-\,z_{\text{camera}}}, 
    \quad
    y_{\text{ndc}} = \frac{Y_c}{W_c} = \frac{Y_c}{-\,z_{\text{camera}}},
    \quad
    z_{\text{ndc}} = \frac{Z_c}{W_c}.
    $$

    Dividing by \$-z\_{\text{camera}}\$ implements the foreshortening perspective effect, and \$z\_{\text{ndc}}\$ preserves depth for the Z-buffer.

## 2. The Viewport Transformation Matrix (`M_viewport`)

* **Purpose:**
  The viewport transformation is the final step before rendering to the screen. It takes the 3D point in NDC space $\[-1,1]\$ (after the perspective divide and clipping) and maps its X and Y coordinates to the 2D pixel coordinates \$(u\_m, v\_m)\$ on the screen. It also maps the NDC Z coordinate to a depth value suitable for the depth buffer.

* **Screen Parameters:**
  The dimensions of the target display area, typically its `Width` (W) and `Height` (H) in pixels.

* **Mapping from NDC to Screen:**

  * \$u\_m = x\_{\text{ndc}} \cdot \frac{W}{2} + \frac{W}{2}\$
  * \$v\_m = y\_{\text{ndc}} \cdot \frac{H}{2} + \frac{H}{2}\$
  * \$z\_{\text{depth}} = z\_{\text{ndc}} \cdot \frac{1}{2} + \frac{1}{2}\$

* **The Matrix Form:**
  These can be expressed as a homogeneous 4×4 matrix:

  $$
  \mathbf{M_{viewport}}
  =
  \begin{pmatrix}
    \tfrac{W}{2} & 0 & 0 & \tfrac{W}{2} \\
    0 & \tfrac{H}{2} & 0 & \tfrac{H}{2} \\
    0 & 0 & \tfrac{1}{2} & \tfrac{1}{2} \\
    0 & 0 & 0 & 1
  \end{pmatrix}
  $$

  When multiplied by \$(x\_{\text{ndc}}, y\_{\text{ndc}}, z\_{\text{ndc}}, 1)\$, the first row yields \$u\_m\$, the second \$v\_m\$, and the third \$z\_{\text{depth}}\$.

In summary, the specific forms and coefficients of these matrices are not arbitrary. They are carefully constructed algebraic representations of the geometric transformations required to map coordinates from one space to another—frustum to NDC, and NDC to screen—implementing the precise scaling, translation, and perspective‐division effects that define the graphics pipeline. The parameters (l, r, b, t, n, f, W, H) define the geometry of the input (frustum) and output (screen) spaces, and the matrix coefficients are derived to perform the exact mapping between them.

