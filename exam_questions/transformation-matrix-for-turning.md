# Transformation matrix for the rotation around the line from the given points

:::{important} Question 3
Soit l'axe $\vec{d}$ défini par les deux points $P_1\,(1,\,2,\,-4)$ et $P_2\,(3,\,1,\,7)$. Définir la matrice de transformation de rotation de $45^\circ$ autour de l’axe $\vec{d}$. On exprimera cette matrice sous forme d’un produit de matrices canoniques. Il n’est pas nécessaire d’effectuer les multiplications explicites.
:::

Détaillons chacune des étapes, en justifiant leur rôle, en expliquant comment fonctionnent les matrices et ce que représentent α, β, etc.

---

### 1. Trouver le vecteur directeur $\vec u$ de l’axe

* **On a** deux points $P_1=(1,2,-4)$ et $P_2=(3,1,7)$.
* **Le vecteur directeur** $\vec u=P_2 - P_1$ pointe dans la direction de l’axe :

  $$
    \vec u = (3-1,\;1-2,\;7-(-4)) = (2,\,-1,\;11).
  $$
* **Pourquoi ?**
  Pour définir une droite en 3D, on a besoin

  1. d’un point $P_1$ qu’elle contient,
  2. d’une direction $\vec u$.
     Ce vecteur sert à orienter toutes nos rotations ultérieures.

---

### 2. Translation pour poser $P_1$ à l’origine

* **Matrice** de translation de $-P_1$ :

  $$
    T_{-P_1} = 
    \begin{pmatrix}
      1 & 0 & 0 & -1\\
      0 & 1 & 0 & -2\\
      0 & 0 & 1 & +4\\
      0 & 0 & 0 & 1
    \end{pmatrix}.
  $$

  Appliquée à un point homogène $\bigl[x,y,z,1\bigr]^T$, on obtient $(x-1,y-2,z+4)$.

* **Pourquoi ?**
  Les rotations que nous connaissons (autour de $Ox,Oy,Oz$) sont centrées à l’origine.
  En “ramenant” $P_1$ à $(0,0,0)$, on pourra aligner et faire tourner l’axe proprement autour de l’origine.

---

### 3. Rotation autour de $Oz$ pour annuler la composante $y$ de $\vec u$

1. **Projection dans le plan $xy$** :
   $\pi_{xy}(\vec u) = (u_x,u_y) = (2,-1)$.

2. **Angle α** :

   $$
     \alpha = \arg(2 - i\,1) = \arctan2(u_y,u_x) = \arctan2(-1,2).
   $$

   Numériquement, $\alpha \approx -26{,}6^\circ$.

3. **Rotation inverse** $R_z(-\alpha)$ :

   $$
     R_z(-\alpha)
     = \begin{pmatrix}
         \cos(-\alpha) & -\sin(-\alpha) & 0 \\
         \sin(-\alpha) &  \cos(-\alpha) & 0 \\
         0             &  0             & 1
       \end{pmatrix}.
   $$

   Après cette rotation, le vecteur $\vec u$ devient

   $$
     R_z(-\alpha)\,\vec u
     = \bigl(\sqrt{2^2+(-1)^2},\,0,\,11\bigr) = (\sqrt5,\,0,\,11).
   $$

* **Pourquoi ?**
  On “pivote” autour de l’axe $z$ pour faire disparaître la composante $y$ :
  la projection de $\vec u$ tombe alors sur l’axe $x$.
  Cela simplifie l’étape suivante car on n’a plus qu’un plan $xz$.

---

### 4. Rotation autour de $Oy$ pour aligner entièrement sur $Oz$

1. **Longueur dans le plan $xz$** :

   $$
     r = \sqrt{(\sqrt5)^2 + 0^2} = \sqrt5.
   $$

2. **Angle β** :

   $$
     \beta = \arctan\!\frac{r}{u_z} = \arctan\!\frac{\sqrt5}{11}.
   $$

   C’est l’angle entre le vecteur $(r,0,11)$ et l’axe $Oz$.

3. **Rotation inverse** $R_y(-\beta)$ :

   $$
     R_y(-\beta)
     = \begin{pmatrix}
         \cos(-\beta) & 0 & \sin(-\beta) \\
         0            & 1 & 0            \\
        -\sin(-\beta)& 0 & \cos(-\beta)
       \end{pmatrix}.
   $$

   Elle envoie $\bigl(r,0,11\bigr)$ sur $\bigl(0,0,\sqrt5^2+11^2\bigr) = (0,0,\|\vec u\|)$.

* **Pourquoi ?**
  On tourne autour de l’axe $y$ pour “redresser” le vecteur $\vec u$ sur l’axe $z$.
  Après $R_z(-\alpha)$ et $R_y(-\beta)$, l’axe $\vec d$ coïncide exactement avec $Oz$.

---

### 5. Rotation d’angle $\theta=45^\circ$ autour de l’axe $Oz$

* **Matrice** :

  $$
    R_z(\theta)
    = \begin{pmatrix}
        \cos\tfrac\pi4 & -\sin\tfrac\pi4 & 0 \\
        \sin\tfrac\pi4 &  \cos\tfrac\pi4 & 0 \\
        0               &  0               & 1
      \end{pmatrix},
    \quad \theta = 45^\circ.
  $$
* **Rôle** :
  C’est la seule rotation “effective” : elle fait tourner l’espace de $45^\circ$ autour de $Oz$ (donc autour de notre axe $\vec d$, maintenant aligné).

---

### 6. Défaire les transformations d’alignement

Pour ramener l’axe et l’origine dans leur position initiale, on applique, dans l’ordre inverse, les inverses des étapes 3–2 :

1. **$R_y(\beta)$** : inverse de $R_y(-\beta)$.
2. **$R_z(\alpha)$** : inverse de $R_z(-\alpha)$.
3. **$T_{P_1}$** : translation de vecteur $(1,2,-4)$, inverse de $T_{-P_1}$.

---

### 7. Composition finale

En coordonnées homogènes, la matrice de la rotation cherchée vaut donc, en appliquant de droite à gauche :

$$
\boxed{
M \;=\;
T_{P_1}
\;\;
R_z(\alpha)
\;\;
R_y(\beta)
\;\;
R_z\bigl(45^\circ\bigr)
\;\;
R_y(-\beta)
\;\;
R_z(-\alpha)
\;\;
T_{-P_1}.
}
$$

* **Interprétation** :

  1. Translation pour centrer $P_1$.
  2. Deux rotations élémentaires pour aligner l’axe arbitraire sur $Oz$.
  3. Rotation de $45^\circ$ autour de cet axe.
  4. Inversion des deux rotations d’alignement.
  5. Translation inverse.

* **Pourquoi laisser sous forme de produit ?**
  Cela garde la structure géométrique claire :

  * chaque matrice est simple,
  * on peut changer facilement l’angle, ou le point $P_1$,
  * aucun calcul matriciel lourd n’est nécessaire pour comprendre la construction.

---

**Récapitulatif des symboles**

* $T_{-P_1},\,T_{P_1}$ : translations.
* $R_z(\phi)$ : rotation‐élémentaire autour de l’axe $z$ d’angle $\phi$.
* $R_y(\psi)$ : rotation‐élémentaire autour de l’axe $y$ d’angle $\psi$.
* $\alpha = \arctan2(u_y,u_x)$ : angle de la projection dans le plan $xy$.
* $\beta = \arctan\!\tfrac{\sqrt{u_x^2+u_y^2}}{u_z}$ : angle pour amener le vecteur sur $Oz$.
* $\theta=45^\circ$ : l’angle de rotation final autour de l’axe donné.

Chaque étape sert à transformer un problème de rotation autour d’un axe arbitraire en une rotation autour d’un axe coordonné plus simple, puis à revenir à la configuration initiale.

