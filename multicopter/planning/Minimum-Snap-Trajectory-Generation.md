## Minimum Snap Trajectory Generation

##### 2021/09/02

Contents of this document is based on the following reference:

D. Mellinger and V. Kumar, "Minimum Snap Trajectory Generation and Control for Quadrotors," in IEEE International Conference on Robotics and Automation, 2011.



#### Piecewise polynomial trajectory

Consider the following piecewise polynomial trajectory $w(t):\mathbb{R} \rightarrow \mathbb{R}$.
$$
w(t) =
\begin{cases}
w_{1}(t) & t_{0} \le t \le t_{1} \\
\vdots \\
w_{m}(t) & t_{m - 1} \le t \le t_{m}
\end{cases}
$$
where each $w_{i}(t)$ is a polynomial of order $n$​. Each polynomial $w_{i}(t)$ can be expressed as
$$
\begin{align}
w_{i}(t) &= c_{i,n}t^{n} + c_{i,n-1}t^{n-1} + \cdots + c_{i,0} \\
&= \begin{bmatrix}
t^{n} & t^{n-1} & \cdots & 1
\end{bmatrix} \begin{bmatrix}
c_{i, n} \\ c_{i, n-1} \\ \vdots \\ c_{i, 0}
\end{bmatrix} = b(t)^{T}c_{i}
\end{align}
$$
where $b(t) \in \mathbb{R}^{n + 1}$​​ is the basis vector and $c_{i} \in \mathbb{R}^{n + 1}$​​​​​ is an optimization variable.



#### Smoothness constraint

For $l=1, 2, \cdots, k$​​, the smoothness constraints can be expressed as
$$
\begin{align}
\frac{d^{l}}{dt^{l}}w(t)\Big\vert_{t = t_{i}^{-}}&=\frac{d^{l}}{dt^{l}}w(t)\Big\vert_{t = t_{i}^{+}}\quad (i=1, 2, \cdots, m -1) \\
b^{(l)}(t_{i})^{T}c_{i} &= b^{(l)}(t_{i})^{T}c_{i + 1} \\
&\therefore b^{(l)}(t_{i})^{T}c_{i} - b^{(l)}(t_{i})^{T}c_{i + 1} = 0
\end{align}
$$
In matrix notation,
$$
\begin{bmatrix}
b^{(l)}(t_{1})^{T} & -b^{(l)}(t_{1})^{T} & 0 & \cdots & 0 \\
0 & b^{(l)}(t_{2})^{T} & -b^{(l)}(t_{2})^{T} & \cdots & 0 \\
\vdots & \vdots & \vdots & \vdots & \vdots \\
0 & 0 & \cdots & b^{(l)}(t_{m - 1})^{T} & -b^{(l)}(t_{m - 1})^{T}
\end{bmatrix} c = 0
$$
where $c = \begin{bmatrix} c_{1}^{T} & \cdots & c_{m}^{T} \end{bmatrix}^{T}$​.​​



#### Key-frame constraint

Given the desired key-points $w_{d,0}, \cdots, w_{d,m}$, the key-frame constraint can be expressed as
$$
\begin{align}
w(t_{i}) &= w_{d, i} \quad (i=0, 1, \cdots, m) \\
b(t_{i})^{T}c_{i} &= w_{d, i}
\end{align}
$$
In matrix notation,
$$
\begin{bmatrix}
b(t_{0})^{T} & 0 & \cdots & 0 \\
0 & b(t_{1})^{T} & \cdots & 0 \\
\vdots & \vdots & \vdots & \vdots \\
0 & 0 & \cdots & b(t_{m})^{T}
\end{bmatrix}c = \begin{bmatrix}
w_{d, 0} \\ w_{d, 1} \\ \vdots \\ w_{d, m}
\end{bmatrix}
$$


#### Endpoint constraint

For $l=1, 2, \cdots, k$, constraints at the initial point and final point can be expressed as
$$
b^{(l)}(t_{0})^{T}c_{0} = 0\textrm{ or free};\quad b^{(l)}(t_{m})^{T}c_{m} = 0\textrm{ or free}
$$


#### Cost function

$$
\begin{align}
\int_{t_{0}}^{t_{m}}\left( \frac{d^{k}(\tau)}{d\tau^{k}} \right)^{2}d\tau &=
\sum_{i = 1}^{m}\int_{t_{i - 1}}^{t_{i}} \left( \frac{d^{k}(\tau)}{d\tau^{k}} \right)^{2}d\tau \\
&= \sum_{i = 1}^{m}c_{i}^{T}\int_{t_{i - 1}}^{t_{i}}b^{(k)}(\tau)b^{(k)}(\tau)^{T}d\tau \\
&= c^{T}\mathrm{blockdiag} \left( \int_{t_{i - 1}}^{t_{i}}b^{(k)}(\tau)b^{(k)}(\tau)^{T}d\tau \right)c \\
&= c^{T}\mathrm{blockdiag}(H_{i})c
\end{align}
$$



#### Temporal scaling

Using the min-max normalization,
$$
\tilde{t}:= \frac{t - t_{\min}}{t_{\max} - t_{\min}};\quad t = t_{\min} + (t_{\max} - t_{\min})\tilde{t}
$$
where $t_{\max}=t_{m}$ and $t_{\min}=t_{0}$.



#### Spatial scaling

Using the min-max normalization,
$$
\tilde{w}:=\frac{w - w_{\min}}{w_{\max} - w_{\min}};\quad w = w_{\min} + (w_{\max} - w_{\min})\tilde{w}
$$
where $w_{\min}=\min\{w_{d, 0},\cdots, w_{d,m}\}$ and $w_{\max}=\max\{w_{d, 0},\cdots, w_{d,m}\}$​.



#### Minimum snap trajectory

The trajectory for the quadrotor is defined as
$$
\sigma(t) = \begin{bmatrix}
x(t) \\ y(t) \\ z(t) \\ \psi(t)
\end{bmatrix}
$$
where each $x(t), y(t), z(t), \psi(t)$​ is a piecewise polynomial.