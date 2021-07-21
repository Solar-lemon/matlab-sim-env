## Quadrotor Quaternion Control

##### 2021/07/17

The content of this document is based on the following reference:

J. Carino, H. Abaunza and P. Castillo, 2015, "Quadrotor Quaternion Control"



#### Attitude Control

The axis-angle representation $\overline{\theta}$ can be obtained as $\overline{\theta}=2\ln\boldsymbol{q}$. The attitude dynamic model becomes
$$
\begin{align}
\frac{d}{dt}\begin{bmatrix}
\overline{\theta} \\ \omega
\end{bmatrix} &= \begin{bmatrix}
0_{3\times 3} & I_{3} \\
0_{3\times 3} & 0_{3\times 3}
\end{bmatrix}\begin{bmatrix}
\overline{\theta} \\
\omega
\end{bmatrix} + \begin{bmatrix}
0_{3 \times 3} \\ I_{3}
\end{bmatrix}u_{att} \\
&= Ax_{att} + Bu_{att}
\end{align}
$$
where
$$
x_{att}=\begin{bmatrix}
2\ln\boldsymbol{q} \\
\omega
\end{bmatrix},\quad \tau = Ju_{att} + \omega \times J\omega
$$
The control law for the attitude dynamic is proposed as
$$
u_{att}=-K_{att}(x_{att} - x_{att, d})
$$
where $x_{att, d}$ is the desired attitude.



#### Position Control

The position dynamic model becomes
$$
\begin{align}
\frac{d}{dt}\begin{bmatrix}
p \\ \dot{p}
\end{bmatrix} &= \begin{bmatrix}
0_{3\times 3} & I_{3} \\
0_{3\times 3} & 0_{3\times 3}
\end{bmatrix}\begin{bmatrix}
p \\
\dot{p}
\end{bmatrix} + \begin{bmatrix}
0_{3 \times 3} \\ I_{3}
\end{bmatrix}u_{pos} \\
&= Ax_{pos} + Bu_{pos}
\end{align}
$$
where
$$
x_{pos}=\begin{bmatrix}
p \\ \dot{p}
\end{bmatrix}
$$
The control law for the position dynamic is proposed as
$$
u_{pos}=-K_{pos}(x_{pos} - x_{pos, d})
$$
where $x_{pos, d}$ is the desired position.

The total thrust $F_{th}$ can be obtained as
$$
\begin{align}
\quad u_{p,d} &= u_{pos} - \overline{g} \\
F_{th} &= m \Vert u_{p, d}\Vert
\end{align}
$$
The desired attitude can be obtained as
$$
\begin{align}
\boldsymbol{r}_{d} &= (n\cdot u_{p, d} + \Vert u_{p, d}\Vert) + n \times u_{p, d} \\
\boldsymbol{q}_{d} &= \frac{\boldsymbol{r}_{d}}{\Vert \boldsymbol{r}_{d}\Vert} \\
\omega_{d} &= 2\boldsymbol{q}_{d}^{\ast}\dot{\boldsymbol{q}}_{d}
\end{align}
$$
To obtain the expression for $\boldsymbol{q}^{\ast}_{d}$, expressions for $\dot{u}_{p,d}$ and $\dot{\boldsymbol{r}}_{d}$ have to obtained first. Assuming constant $x_{pos, d}$,
$$
\dot{u}_{p,d}=\dot{u}_{pos}=-K_{pos}\dot{x}_{pos}=-K_{pos}(Ax_{pos} + Bu_{pos})
$$
In addition,
$$
\begin{align}
\dot{\boldsymbol{r}}_{d} &= \left(n\cdot \dot{u}_{p,d} + \frac{u_{p,d}^{T}\dot{u}_{p,d}}{\Vert u_{p,d}\Vert} \right) + n \times \dot{u}_{p,d} \\
\dot{\boldsymbol{q}_{d}} &= \frac{\dot{\boldsymbol{r}}_{d}}{\Vert \boldsymbol{r}_{d}\Vert} + \boldsymbol{r} \left( -\frac{\boldsymbol{r}_{d}^{T}\dot{\boldsymbol{r}}_{d}}{\Vert \boldsymbol{r}_{d}\Vert^{3}}\right)
\end{align}
$$




