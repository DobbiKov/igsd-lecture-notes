# Lecture: Illumination and Textures

This lecture covers the crucial stages in the graphics pipeline responsible for determining the colour and visual appearance of 3D objects: **Illumination (Shading) and Texture Mapping**. These processes occur after the modelling transformations and before clipping, projection, rasterisation, and visibility determination.

## I. Illumination (Éclairage)

**Illumination** refers to the process of calculating the transport of luminous flux, both directly and indirectly, from light sources within a scene. It can be categorised as **local** or **global**. This lecture primarily focuses on **local illumination models**, where the lighting at a surface point is calculated based only on the properties of the object at that point, the light sources, and the viewer's position, without considering light interactions between different objects (like shadows or reflections).

**Éclairement (Illuminance)** is the calculation of the luminous intensity at a specific point on a surface in the scene. It involves a model of interaction between a light source and the illuminated point.

The **illumination** at a point depends on several factors:

*   **Position of the point in space**.
*   **Orientation of the point (surface normal)**.
*   **Characteristics of the surface** (e.g., how much it diffuses or reflects light, its transparency).
*   **Sources of light** (their type, position, direction, intensity).
*   **Position and orientation of the “camera” or viewpoint**.

### A. Sources of Light

Different types of light sources are used to simulate various lighting conditions:

*   **Ambient Light:** This light illuminates the entire scene uniformly from all directions. It is the simplest model, characterised only by its **intensity**. It's often used to provide a minimum level of lighting to prevent objects in shadow from being completely black. However, it does not convey any sense of 3D form.
*   **Point Sources:** These light sources are located at a specific point in 3D space and radiate light radially in all directions. They are characterised by their **intensity**, **position**, and a **falloff function** that determines how the light intensity decreases with distance. Point sources can be **isotropic** (radiating equally in all directions) or **anisotropic** (radiating more strongly in some directions). When a point source has volume, it becomes an **extended source**.
*   **Directional Sources:** These sources are assumed to be infinitely far away and illuminate the scene with parallel rays in a given **direction**. They are characterised by their **intensity** and **direction**. A common example is sunlight.
*   **Spot Sources (Projector Lights):** These sources are defined by their **position**, **direction**, and a **concentration factor** that controls the focus of the light beam. They emit light in a cone along their specified direction.

### B. Models of Illumination (Éclairement)

Local illumination models calculate the light intensity at a point by considering different components:

*   **Emitted Light:** This represents light that an object inherently produces. In many standard rendering scenarios, objects are not intrinsic emitters of light and thus do not illuminate other objects. However, they may have a minimum level of self-illumination.
*   **Ambient Light:** As discussed with light sources, the ambient illumination component calculates the contribution of a uniform, omnidirectional light source. The intensity at a point due to ambient light ($I_a$) is calculated as:
    $I_a = p_a \cdot I_{La}$
    where $p_a$ is the **ambient reflection coefficient** of the surface material and $I_{La}$ is the **intensity of the ambient light source**. This is often calculated per colour component.
*   **Diffuse Reflection:** This models light that is scattered equally in all directions from a surface. The intensity of diffuse reflection ($I_d$) at a point depends on the angle ($\theta$) between the incident light ray ($\mathbf{L}$) and the surface normal ($\mathbf{N}$) at that point. The formula is based on **Lambert's Law**:
    $I_d = p_d \cdot I_L \cdot \cos(\theta) = p_d \cdot I_L \cdot (\mathbf{N} \cdot \mathbf{L})$
    where $p_d$ is the **diffuse reflection coefficient** of the surface material and $I_L$ is the **intensity of the light source**. $\mathbf{N}$ and $\mathbf{L}$ are normalised vectors. The dot product $(\mathbf{N} \cdot \mathbf{L})$ is clamped to zero to handle cases where the light is behind the surface ($\theta > 90^\circ$).
*   **Specular Reflection (Brillance):** This models the mirror-like reflection of light from a surface, resulting in highlights. The intensity of specular reflection is highly view-dependent. Two common models are:
    *   **Phong Model (1973):** This model calculates a reflection vector ($\mathbf{R}$) by reflecting the light vector $\mathbf{L}$ across the surface normal $\mathbf{N}$. The specular intensity ($I_s$) depends on the angle ($\theta'$) between the reflection vector $\mathbf{R}$ and the viewing direction vector ($\mathbf{V}$):
        $I_s = p_s \cdot I_L \cdot \cos(\theta')^n = p_s \cdot I_L \cdot (\mathbf{R} \cdot \mathbf{V})^n$
        where $p_s$ is the **specular reflection coefficient**, $I_L$ is the light intensity, and $n$ is the **shininess exponent** (or **roughness**), which controls the size and sharpness of the specular highlight. A higher $n$ results in a smaller, more intense highlight (simulating a smoother surface), while a lower $n$ produces a larger, more diffuse highlight (rougher surface).
    *   **Blinn-Phong Model (1977):** This is a more efficient approximation of the Phong model. Instead of calculating the reflection vector $\mathbf{R}$, it introduces a **half-vector** ($\mathbf{H}$) which is the normalised sum of the light vector $\mathbf{L}$ and the view vector $\mathbf{V}$:
        $\mathbf{H} = \frac{\mathbf{L} + \mathbf{V}}{||\mathbf{L} + \mathbf{V}||}$
        The specular intensity is then calculated based on the angle ($\theta''$) between the half-vector $\mathbf{H}$ and the surface normal $\mathbf{N}$:
        $I_s = p_s \cdot I_L \cdot \cos(\theta'')^n = p_s \cdot I_L \cdot (\mathbf{N} \cdot \mathbf{H})^n$
        This avoids the relatively expensive reflection vector calculation.

The complete local illumination model often combines these components, possibly with an **attenuation factor** ($F_d$) to account for the distance between the light source and the illuminated point:

$I(P) = p_a \cdot I_a + F_d \cdot (p_d \cdot I_L \cdot (\mathbf{N} \cdot \mathbf{L}) + p_s \cdot I_L \cdot (\mathbf{R/H} \cdot \mathbf{V/N})^n )$

### C. Colour, Transparency, and Halos

Illumination models are often applied to each colour component (Red, Green, Blue) separately, using the material properties and light source intensities for each component.

**Transparency** can be incorporated by blending the calculated colour of the object with the colour of the background behind it. A **transparency parameter** ($t$) determines the weight of each colour:

$I = t \cdot I(P)_{object} + (1-t) \cdot I_{background}$

**Halos** (or transmission effects) can occur with transparent objects where the colour depends on the thickness of the material the light passes through.

## II. Shading (Ombrage)

**Shading** is the process of using the illumination model to determine the colour of each pixel that represents a 3D surface. Different shading techniques exist, which affect the smoothness and realism of the rendered surfaces:

### A. Local Shading Models

These models calculate the luminance at a surface point based on the object's parameters and the light source parameters.

*   **Flat Shading:** This is the simplest shading method where a single colour and intensity are calculated for an entire polygon (face). The normal vector for the entire face is used in the illumination calculations. This results in a faceted appearance for curved surfaces.
*   **Lambert Shading:** This specifically refers to applying only the diffuse reflection component (based on Lambert's Law) uniformly across a polygon. Like flat shading, it uses a single normal for the entire face and does not produce highlights.
*   **Gouraud Shading (1971):** This technique aims to eliminate the intensity discontinuities across polygonal faces by **interpolating the light intensities calculated at the vertices** of the polygon.
    1.  Calculate the surface normal at each vertex, often by averaging the normals of the faces sharing that vertex.
    2.  Apply the chosen illumination model at each vertex to calculate an intensity (or colour).
    3.  During rasterisation, linearly interpolate these vertex intensities across the edges of the polygon and then between the edges for each scan line.
    Gouraud shading is efficient and widely used, providing a smoother appearance than flat shading. However, it can miss specular highlights that fall in the middle of a polygon and can produce Mach banding effects in areas of rapidly changing intensity.
*   **Phong Shading (1973):** This method provides even smoother shading and can handle specular highlights more effectively than Gouraud shading. Instead of interpolating intensities, **Phong shading interpolates the normal vectors at the vertices** across the polygon.
    1.  Calculate the surface normal at each vertex.
    2.  During rasterisation, linearly interpolate these vertex normals across the edges and then across the scan lines of the polygon.
    3.  At each pixel within the polygon, normalise the interpolated normal and then apply the chosen illumination model to calculate the final colour.
    Phong shading generally produces more realistic results, especially for specular reflections, as the highlights can appear within the faces of polygons. However, it is computationally more expensive than Gouraud shading because the illumination model needs to be evaluated at each pixel.

## III. Textures (Plaquage, Mappage)

**Texture mapping** is a technique used to add fine surface detail to 3D objects without increasing the geometric complexity (number of polygons). Instead of defining colour and other attributes per vertex, an image (the texture) is "glued" or mapped onto the surface of the object.

### A. Texture Coordinates

To map a texture onto an object, **texture coordinates** (typically denoted as $(u, v)$) are associated with each vertex of the 3D model. These coordinates range from 0 to 1 (or sometimes outside this range for tiling or repeating textures) and define how the texture image is stretched or compressed to fit the object's surface. During rasterisation, these texture coordinates are **interpolated across the surface of the polygon** for each fragment (pixel).

### B. Types of Textures

Various types of textures can be used to control different surface properties:

*   **Colour Map (Diffuse Map, Albedo):** This texture directly defines the base colour of the object's surface.
*   **Transparency Map (Alpha Channel):** This texture controls the opacity of the object, allowing for see-through effects.
*   **Bump Maps (Normal Maps, Displacement Maps, Height Maps):** These textures are used to simulate surface relief and detail without altering the underlying geometry.
    *   **Bump Maps** perturb the surface normal at each point based on the texture value, affecting how light reflects and creating the illusion of bumps and dents.
    *   **Normal Maps** directly store the perturbed normal vectors in the texture, providing a more accurate way to simulate surface detail.
    *   **Displacement Maps** actually displace the vertices of the geometry based on the texture value, changing the object's shape.
*   **Specular Maps (Specular Intensity, Shininess, Roughness, Metallic):** These textures control the properties of specular reflections, such as their colour, intensity, and size.
*   **Environment Maps (Cube Maps, Spherical Maps):** These textures store the surrounding environment and are used to simulate reflections on shiny surfaces.
*   **Light Maps:** These textures store pre-calculated illumination information (e.g., shadows, global illumination) to reduce the computational cost of real-time rendering.
*   **Others:** Various other texture types exist for specialised effects, such as occlusion maps, emissive maps, subsurface scattering maps, and more.

### C. Texture Mapping Process and Issues

During rendering, for each fragment (pixel) covered by a textured polygon, the interpolated $(u, v)$ texture coordinates are used to look up the corresponding colour or attribute value from the texture image.

However, several issues can arise during texture mapping:

*   **Magnification (Camera close to the object):** When a single pixel on the screen corresponds to a very small area of the texture, the texture may appear blocky or pixelated. **Filtering techniques** are used to interpolate between texels (texture pixels) to produce a smoother result.
*   **Minification (Camera far from the object):** When a single pixel on the screen covers a large area of the texture, simply sampling a single texel can lead to **aliasing** artefacts like jagged edges or moiré patterns. This is because high-frequency details in the texture are undersampled.

### D. Antialiasing for Textures

Several techniques are used to mitigate texture aliasing:

*   **Supersampling:** Rendering the image at a higher resolution and then downsampling (averaging) to the target resolution. This is computationally expensive.
*   **Mipmapping:** Creating pre-filtered, lower-resolution versions of the texture image. The appropriate mipmap level is chosen based on the distance and angle at which the texture is viewed, reducing aliasing and improving performance.
*   **Anisotropic Filtering:** A more sophisticated filtering technique that reduces aliasing better than mipmapping, especially for surfaces viewed at oblique angles.

These lecture notes provide a detailed overview of the concepts of illumination (shading) and texture mapping as presented in the "4-5 lecture". Understanding these concepts is fundamental to creating visually appealing and realistic 3D graphics, as they determine how light interacts with surfaces and how surface detail is represented.
