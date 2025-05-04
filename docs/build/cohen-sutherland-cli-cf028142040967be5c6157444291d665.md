# Analyzing Cohen-Sutherland Algorithm

Voici une résolution détaillée, étape par étape, de l’algorithme de Cohen–Sutherland pour les cinq segments indiqués, dans le rectangle de coins diagonaux $(4,4)$ et $ (10,8)$.

---

### 1. Paramètres et codage des régions

* **Rectangle de clipping**

  $$
    x_{\min}=4,\quad x_{\max}=10,\quad y_{\min}=4,\quad y_{\max}=8.
  $$

* **Code à 4 bits** $\bigl[b_\text{haut},\,b_\text{bas},\,b_\text{droite},\,b_\text{gauche}\bigr]$ pour un point $P(x,y)$ :

  * $b_\text{haut}=1$ si $y>y_{\max}$, sinon 0
  * $b_\text{bas}=1$ si $y<y_{\min}$, sinon 0
  * $b_\text{droite}=1$ si $x>x_{\max}$, sinon 0
  * $b_\text{gauche}=1$ si $x<x_{\min}$, sinon 0

| Point | Coordonnées |  Code $[H,B,D,G]$ |
| :---: | :---------: | :---------------: |
|   A   |    (2,10)   | \[1,0,0,1] = 1001 |
|   B   |    (11,9)   | \[1,0,1,0] = 1010 |
|   C   |    (5,6)    |     \[0,0,0,0]    |
|   D   |    (7,7)    |     \[0,0,0,0]    |
|   E   |    (3,2)    | \[0,1,0,1] = 0101 |
|   F   |    (11,7)   | \[0,0,1,0] = 0010 |
|   G   |    (9,5)    |     \[0,0,0,0]    |
|   H   |    (12,5)   | \[0,0,1,0] = 0010 |
|   I   |    (2,7)    | \[0,0,0,1] = 0001 |
|   J   |    (6,9)    | \[1,0,0,0] = 1000 |

---

### 2. Traitement segment par segment

Pour chaque segment $[P_1P_2]$ on calcule :

1. **AND** des codes :

   * si ≠ 0 → trivial reject (tout à l’extérieur, même zone)
   * si = 0 mais tous les deux codes = 0 → trivial accept (tout à l’intérieur)
   * sinon → il faut couper (clip) successivement les extrémités hors-rectangle.

#### 2.1 Segment \[AB]

* Codes : A = 1001, B = 1010 → **AND = 1000 ≠ 0** (bit “haut” commun)
* **Conclusion** : le segment est entièrement au-dessus de $y=8$.
* **Action** : rejet trivial, aucune portion n’est dans le rectangle.

---

#### 2.2 Segment \[CD]

* Codes : C = 0000, D = 0000 → **AND = 0000** et tous deux nuls
* **Conclusion** : le segment est entièrement à l’intérieur.
* **Clipping** : pas de découpage, on garde $\bigl[(5,6),(7,7)\bigr]$.

---

#### 2.3 Segment \[EF]

* Codes : E = 0101 (bas+gauche), F = 0010 (droite) → **AND = 0000** → découpage nécessaire.

**Étape 1 :** traiter E (code bas+gauche)

* On examine d’abord le bit “bas” → intersection avec $y=4$.
* Paramètre $t$ sur la droite $\overline{EF}$ :

  $$
    y = 2 + 5t = 4 \;\Longrightarrow\; t = \frac{2}{5} = 0{,}4.
  $$
* Coordonnée correspondante :

  $$
    x = 3 + 8\cdot0{,}4 = 6{,}2.
  $$
* **Point d’entrée** dans le rectangle :

  $$
    P_1 = (6{,}2,\;4).
  $$

**Étape 2 :** traiter F (code droite) sur le segment $P_1F$

* Intersection avec $x=10$.
* Soit $P_1=(6{,}2,4)$, $F=(11,7)$, vecteur $(\Delta x,\Delta y)=(4{,}8,3)$.
* On cherche $t'$ tel que $6{,}2 + 4{,}8\,t' = 10 \Rightarrow t' = \tfrac{3{,}8}{4{,}8} \approx 0{,}7917$.
* Coordonnée $y$ :

  $$
    y = 4 + 3\cdot0{,}7917 \approx 6{,}375.
  $$
* **Point de sortie** :

  $$
    P_2 \approx (10,\;6{,}375).
  $$

**Résultat** pour \[EF] :

$$
  \bigl[(6{,}2,\,4),\,(\,10,\,6{,}375)\bigr].
$$

---

#### 2.4 Segment \[GH]

* Codes : G = 0000, H = 0010 → **AND = 0000**, découpage nécessaire (H hors à droite).

**Clip de H** sur $x=10$ sur la ligne de hauteur constante $y=5$ :

$$
  G=(9,5)\,\to\,H=(12,5)\quad\Longrightarrow\quad P=(10,5).
$$

**Résultat** pour \[GH] :

$$
  \bigl[(9,5),\,(10,5)\bigr].
$$

---

#### 2.5 Segment \[IJ]

* Codes : I = 0001 (gauche), J = 1000 (haut) → **AND = 0000**, découpage en deux passes.

**1. Clip de I (gauche) sur $x=4$** sur $\overline{IJ}$ :

$$
  I=(2,7),\;J=(6,9)\;\Longrightarrow\;
  t = \frac{4-2}{6-2} = \tfrac{2}{4} = 0{,}5,\quad
  P_1 = (4,\;7 + 2\cdot0{,}5) = (4,8).
$$

**2. Clip de J (haut) sur $y=8$** entre $P_1=(4,8)$ et $J=(6,9)$ :

$$
  y = 8 + (9-8)\,t = 8 \;\Rightarrow\; t=0 
  \;\Longrightarrow\; \text{même point }(4,8).
$$

On obtient un **segment dégénéré** :

$$
  P_1 = P_2 = (4,\,8).
$$

---

### 3. Synthèse des résultats

| Segment | Codes extrémités |       Décision       | Portion dans le rectangle               |
| :-----: | :--------------: | :------------------: | :-------------------------------------- |
|  \[AB]  |  1001 ∧ 1010 ≠ 0 |     rejet trivial    | —                                       |
|  \[CD]  |  0000 ∧ 0000 = 0 |    accept trivial    | $\bigl[(5,6),(7,7)\bigr]$               |
|  \[EF]  |  0101 ∧ 0010 = 0 |  clip (2 réflexions) | $\bigl[(6.2,\,4),\,(10,\,6.375)\bigr]$  |
|  \[GH]  |  0000 ∧ 0010 = 0 |     clip (droite)    | $\bigl[(9,5),\,(10,5)\bigr]$            |
|  \[IJ]  |  0001 ∧ 1000 = 0 | clip (gauche → haut) | point unique $(4,8)$ (segment dégénéré) |

Chaque étape de découpage applique systématiquement le premier bit non-nul (haut, bas, droite ou gauche), calcule l’intersection, met à jour le point, puis passe à l’autre extrémité tant que son code reste non nul.

