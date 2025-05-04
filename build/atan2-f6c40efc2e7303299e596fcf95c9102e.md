# Understanding atan2 function

---

## ⚠️ Why Do Signs Differ in atan2?

Because in 2D space, **the same slope (dy/dx)** can belong to **two completely different directions** — depending on the **signs of `x` and `y`**, which determine the **quadrant**.

Let’s break this down:

---

### 🎯 Tangent Only Knows the Slope, Not the Direction

The regular inverse tangent (`atan(y/x)`) only gives you the angle **from the positive x-axis** and doesn’t know what quadrant the vector is in.

For example:

```python
atan(3/2) ≈ 56.3°
atan(-3/-2) = atan(3/2) ≈ 56.3°
```

So both `(3,2)` and `(-3,-2)` give the same result — **but they're in opposite quadrants!**

---

### 🧭 Enter `atan2(dy, dx)`

`atan2(y, x)` **uses the signs of both `x` and `y`** to return the angle in the correct quadrant.

Here’s how it resolves direction:

| Quadrant | x sign | y sign | `atan2(y, x)` result |
| -------- | ------ | ------ | -------------------- |
| I        | +      | +      | 0 to +π/2            |
| II       | -      | +      | +π/2 to +π           |
| III      | -      | -      | -π to -π/2           |
| IV       | +      | -      | -π/2 to 0            |

This means:

* `(3,2)` is in **Quadrant I** → angle ≈ +56.3°
* `(-3,-2)` is in **Quadrant III** → angle ≈ **-123.7°**

Both have the **same dy/dx = 2/3**, but the **direction is flipped** — and so is the sign of the angle.

---

### 🧠 Intuition with Geometry

Imagine a unit circle. You draw a line from the origin to point `(3, 2)` and another to `(-3, -2)`.

* They both form a triangle with **same shape** (i.e., same slope),
* But they're on **opposite sides** of the origin,
* So the angle from the positive x-axis must reflect that → one is positive, the other negative (or over π radians).

---

### ✅ Why This Matters

If you only used `atan(dy/dx)`, you'd get the **same result** for both vectors — and your object might rotate in the **wrong direction**, e.g., rotating left instead of right.

**`atan2` fixes this** by:

* Disambiguating the quadrant,
* Preserving sign,
* Providing smooth, consistent angular rotation across the full circle.

---

Would you like a quadrant-by-quadrant demo showing how `atan2` behaves as a vector moves around the origin?

